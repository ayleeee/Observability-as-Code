from flask import Flask, request
import logging
import time
import random
from opentelemetry import trace
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor

app = Flask(__name__)

# Initialize Tracer
resource = Resource(attributes={"service.name": "flask"})
trace.set_tracer_provider(TracerProvider(resource=resource))
tracer = trace.get_tracer(__name__)

otlp_exporter = OTLPSpanExporter(endpoint="http://localhost:4317")
try:
    span_processor = BatchSpanProcessor(otlp_exporter)
    trace.get_tracer_provider().add_span_processor(span_processor)
except Exception as e:
    app.logger.error(f"Failed to add span processor: {e}")


# Setup Prometheus-style metrics endpoint
start_time = time.time()

@app.route('/metrics')
def metrics():
    uptime = time.time() - start_time
    cpu_usage = random.uniform(0, 100)  # Simulate CPU usage in percentage
    response = (
        f"# HELP app_uptime_seconds The uptime of the application in seconds\n"
        f"# TYPE app_uptime_seconds gauge\n"
        f"app_uptime_seconds {uptime}\n"
        f"# HELP app_cpu_usage_percent Simulated CPU usage percentage\n"
        f"# TYPE app_cpu_usage_percent gauge\n"
        f"app_cpu_usage_percent {cpu_usage}\n"
    )
    return response, 200, {'Content-Type': 'text/plain; charset=utf-8'}

# Endpoint to generate trace-like and log-like information
@app.route('/api/some-operation', methods=['POST'])
def some_operation():
    with tracer.start_as_current_span("some_operation") as span:
        app.logger.info("Some operation called, processing...")
        try:
            if random.choice([True, False]):
                app.logger.warning("A potential issue occurred during processing.")
                span.set_attribute("operation.warning", True)  # 트레이스에 경고 속성 추가
                return "Warning: Potential issue occurred", 200
            else:
                span.set_attribute("operation.success", True)  # 트레이스에 성공 속성 추가
                return "Operation completed successfully", 200
        except Exception as e:
            app.logger.error(f"Error during some operation: {e}")
            span.set_attribute("operation.error", str(e))  # 트레이스에 오류 속성 추가
            return "Internal server error", 500


# Hello World endpoint
@app.route('/')
def hello_world():
    return "Hello, World!"

if __name__ == '__main__':
    # Setup basic logging
    logging.basicConfig(level=logging.INFO, filename='app.log',
                        format='%(asctime)s %(levelname)s %(message)s', datefmt='%Y-%m-%d %H:%M:%S')
    app.run(host='0.0.0.0', port=5000)
