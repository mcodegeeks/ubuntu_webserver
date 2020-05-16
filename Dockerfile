FROM python:3

# Set working directory
WORKDIR /usr/src/app

# Add application
ADD ./app $WORKDIR

# Upgrade python package installer
RUN pip install --upgrade pip

# Install requirements
RUN pip install --no-cache-dir -r requirements.txt

# Run server
CMD python wsgi.py run -h 0.0.0.0
