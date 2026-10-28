# DevOps CI/CD Automation Project: GitHub &rarr; Jenkins &rarr; Docker &rarr; Docker Hub &rarr; Local Deployment

A complete end-to-end automated Continuous Integration and Continuous Deployment (CI/CD) project deployed on Fedora Linux.

---

## 🌟 Overview

This project showcases a complete DevOps delivery lifecycle:
1. **Source Code Management**: Code hosted on GitHub.
2. **CI/CD Automation Engine**: Jenkins Declarative Pipeline.
3. **Containerization**: Docker with an ultra-lightweight `nginx:alpine` image.
4. **Artifact Registry**: Docker Hub registry push with dual tagging (`build-number` & `latest`).
5. **Deployment**: Automatic pull and run on Fedora host mapped to `http://localhost:8081`.
6. **Automated Verification**: Built-in HTTP health check verifying 200 OK responses.

---

## 📁 Repository Structure

```
jenkins-docker-demo/
├── .gitignore               # Git ignored patterns & security exclusions
├── Dockerfile               # Container build configuration using nginx:alpine
├── Jenkinsfile              # Declarative multi-stage CI/CD pipeline
├── README.md                # Comprehensive project documentation
└── project/
    ├── index.html           # DevOps Dashboard interface
    ├── style.css            # Dark mode styling and responsiveness
    └── script.js            # Interactive controls & live health probes
```

---

## 🚀 Quick Start (Local Docker Testing)

To build and run the application locally without Jenkins:

```bash
# 1. Build the Docker container image
docker build -t jenkins-docker-demo:local .

# 2. Run container mapping host port 8081 to container port 80
docker run -d --name jenkins-docker-demo-local -p 8081:80 jenkins-docker-demo:local

# 3. Test with curl
curl -I http://localhost:8081

# 4. View container logs
docker logs jenkins-docker-demo-local

# 5. Cleanup
docker stop jenkins-docker-demo-local && docker rm jenkins-docker-demo-local
```

Visit **http://localhost:8081** in your browser.

---

## ⚙️ Jenkins CI/CD Pipeline

The `Jenkinsfile` defines a 7-stage pipeline:
1. **SCM Checkout**: Clones latest code from the Git repository.
2. **Code & Structure Validation**: Verifies `Dockerfile`, `index.html`, `style.css`, and `script.js` exist.
3. **Docker Build**: Builds the container image using the project's Dockerfile.
4. **Image Tagging**: Tags the image with both `${BUILD_NUMBER}` and `latest`.
5. **Docker Hub Authentication & Push**: Authenticates using Jenkins credentials `dockerhub-creds` and pushes both tags.
6. **Deploy Application**: Stops existing containers and runs the newly published image on port 8081.
7. **Health Check Verification**: Curls `http://localhost:8081` until HTTP 200 is confirmed.

---

## 🔐 Credentials Setup

In Jenkins:
1. Go to **Manage Jenkins** &rarr; **Credentials** &rarr; **System** &rarr; **Global credentials**.
2. Click **Add Credentials**.
3. Select **Kind**: `Username with password`.
4. **Username**: Your Docker Hub username.
5. **Password**: Your Docker Hub Personal Access Token (PAT).
6. **ID**: `dockerhub-creds` (must match Jenkinsfile).
