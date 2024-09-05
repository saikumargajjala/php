# Use a Python base image
FROM python:3.9-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Set work directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gcc \
        libffi-dev \
        libssl-dev \
        python3-dev \
        default-libmysqlclient-dev \
        pkg-config \
    && python -m pip install --upgrade pip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy and install Python dependencies
COPY requirements.txt /app/
RUN pip install --no-cache-dir --root-user-action=ignore -r requirements.txt

# Copy project files
COPY . /app/

# Set environment variables for Django superuser
ENV DJANGO_SUPERUSER_USERNAME=admin
ENV DJANGO_SUPERUSER_EMAIL=admin@example.com
ENV DJANGO_SUPERUSER_PASSWORD=adminpassword

# Run migrations, create superuser, and collect static files
RUN python manage.py makemigrations && \
    python manage.py migrate && \
    python create_superuser.py && \
    python manage.py collectstatic --no-input


# Expose port
EXPOSE 8000

# Run the Django development server
CMD ["gunicorn", "--bind", ":8000", "slnone.wsgi:application"]