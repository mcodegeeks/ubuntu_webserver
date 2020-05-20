FROM python:3

# Set working directory
WORKDIR /usr/src/app

# Create directories to share among containers
RUN mkdir -p /data/app
RUN mkdir -p /data/nginx
RUN mkdir -p /data/postgres

# Copy application
ADD ./app $WORKDIR

# Upgrade python package installer
RUN pip install --upgrade pip

# Install requirements
RUN pip install --no-cache-dir -r requirements.txt

# Run server
CMD gunicorn -b unix:/data/nginx/gunicorn.sock -b :5000 wsgi:app
