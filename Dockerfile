FROM python:3

# Set working directory
WORKDIR /usr/src/app

# Create a directory for data-volume
RUN mkdir -p /data-volume

# Copy application
ADD ./app $WORKDIR

# Upgrade python package installer
RUN pip install --upgrade pip

# Install requirements
RUN pip install --no-cache-dir -r requirements.txt

# Run server
CMD gunicorn -b unix:/data-volume/nginx/gunicorn.sock -b :5000 wsgi:app
