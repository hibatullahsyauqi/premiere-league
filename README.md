# Premiere League - Spring Boot Application

This is a Spring Boot application that provides a REST API for Premiere League player data.

---

## Technical Assessment - CI/CD Design

### Ideal End-to-End CI/CD Flow

This document outlines the ideal CI/CD flow for both the backend and a conceptual mobile application, orchestrated by Jenkins and deploying to Kubernetes.

#### A. Backend CI/CD Flow (Premiere League API)

1.  **Trigger:** A developer pushes code to a feature branch on GitHub.
2.  **Pull Request (PR):** The developer opens a PR to merge into the `main` branch.
3.  **CI - Jenkins Build & Test:** A GitHub webhook triggers a Jenkins pipeline.
    *   **Checkout:** Jenkins checks out the PR branch code.
    *   **Build:** The app is compiled and packaged into a `.jar` file using `./mvnw package`.
    *   **Test:** Unit and integration tests are run via `./mvnw test`. Pipeline fails if tests fail.
    *   **Code Analysis:** A tool like SonarQube scans for code quality and vulnerabilities.
4.  **CI - Dockerize:** If all previous steps pass:
    *   **Build Image:** Jenkins builds a Docker image using the `Dockerfile`.
    *   **Push Image:** The image is tagged (e.g., with the git commit hash) and pushed to a Docker Registry (in this case, Docker Hub under `hibatullahsyauqi/premiere-league`).
5.  **CD - Deploy to Staging:** After the PR is merged into `main`:
    *   **Trigger:** The merge triggers the deployment part of the pipeline.
    *   **Deploy:** Jenkins uses `kubectl apply` to deploy the manifests from the `k8s/` directory to a **Staging** Kubernetes cluster. The pipeline dynamically updates the image tag in the deployment manifest. Database credentials for staging are injected via Kubernetes Secrets.
6.  **CD - Deploy to Production (Manual Approval):**
    *   After verification in staging, a project lead provides manual approval in Jenkins.
    *   Upon approval, the same process deploys the application to the **Production** Kubernetes cluster, using production-level secrets.

#### B. Mobile CI/CD Flow (Conceptual)

1.  **Trigger & PR:** Same as the backend flow.
2.  **CI - Build & Test:** A Jenkins pipeline builds the `.apk` (Android) or `.ipa` (iOS) and runs tests on emulators.
3.  **CD - Internal Distribution:** The app package is uploaded to a service like Firebase App Distribution for QA testing.
4.  **CD - Store Release (Manual):** Upon approval, the build is manually promoted and uploaded to the Google Play Store or Apple App Store.
