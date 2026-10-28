FROM nginx:alpine

# Metadata labels
LABEL maintainer="DevOps Engineer"
LABEL description="DevOps CI/CD Demo Dashboard"

# Remove default nginx static files
RUN rm -rf /usr/share/nginx/html/*

# Copy project files into nginx document root
COPY project/ /usr/share/nginx/html/

# Expose port 80
EXPOSE 80

# Launch Nginx
CMD ["nginx", "-g", "daemon off;"]
