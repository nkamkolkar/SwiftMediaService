# SwiftMediaService

#Requirements 
https://github.com/nkamkolkar/SwiftMediaService/blob/main/requirements.md

**SwiftMediaService API Documentation**

### Overview

SwiftMediaService is a media storage and streaming API that allows users to upload, retrieve, and manage media files. This document provides an overview of available endpoints and their usage.

---

## **Base URL**

`http://127.0.0.1:8080/`

## **Authentication**

The API uses JWT-based authentication. All protected endpoints require a valid JWT token in the `Authorization` header.

```
Authorization: Bearer <token>
```

---

## **Endpoints**

### **Health Check**

**GET** `/health`

- **Description:** Returns the health status of the service.
- **Response:**
  - `200 OK`: `{"status": "healthy"}`

---

### **File Upload**

**POST** `/upload`

- **Description:** Uploads a file to the server.
- **Headers:**
  - `Authorization: Bearer <token>`
  - `Content-Type: multipart/form-data`
- **Request Body:**
  - `file` (binary) - The file to upload.
- **Response:**
  - `200 OK`: `{ "filePath": "<URL>", "filename": "<name>" }`

---

### **List Uploaded Files**

**GET** `/listing`

- **Description:** Lists all uploaded files.
- **Headers:**
  - `Authorization: Bearer <token>`
- **Response:**
  - `200 OK`: `[ { "filename": "myimg.jpg", "filePath": "<URL>" } ]`

---

### **Download File**

**GET** `/download/:filename`

- **Description:** Downloads a file by filename.
- **Headers:**
  - `Authorization: Bearer <token>`
- **Response:**
  - `200 OK`: File content as binary stream

---

### **View Public Files**

**GET** `/Uploads/YYYY/MM/DD/GUID/filename`

- **Description:** Retrieves a publicly accessible file.
- **Response:**
  - `200 OK`: File content as binary stream
  - `404 Not Found`: If the file does not exist

---

## **Error Handling**

The API returns standard HTTP status codes:

- `200 OK` - Request successful.
- `400 Bad Request` - Invalid input.
- `401 Unauthorized` - Missing or invalid token.
- `403 Forbidden` - Access denied.
- `404 Not Found` - Resource not found.
- `500 Internal Server Error` - Unexpected server error.

For any issues, ensure you are providing the correct headers and payloads.

