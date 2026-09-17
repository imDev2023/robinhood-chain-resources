> ## Documentation Index
> Fetch the complete documentation index at: https://docs.bags.fm/llms.txt
> Use this file to discover all available pages before exploring further.

# File Upload Support

> How to upload images and files through the Bags API

The Bags API supports file uploads for token creation with specific requirements and formats.

## Upload Requirements

* **Maximum file size**: 15MB for image uploads
* **Content-Type**: `multipart/form-data` for file upload endpoints
* **File field name**: `image` (required field name for all image uploads)
* **Supported formats**: PNG, JPG, JPEG, GIF, WebP

## Basic File Upload

### Single Image Upload

<CodeGroup>
  ```bash cURL theme={null}
  curl -X POST 'https://public-api-v2.bags.fm/api/v1/token-launch/create-token-info' \
    -H 'x-api-key: YOUR_API_KEY' \
    -H 'Content-Type: multipart/form-data' \
    -F 'image=@/path/to/your/image.png' \
    -F 'name=My Token' \
    -F 'symbol=MYTOKEN'
  ```

  ```javascript Node.js theme={null}
  // From file input
  const formData = new FormData();
  formData.append('image', fileInput.files[0]);
  formData.append('name', 'My Token');
  formData.append('symbol', 'MYTOKEN');

  const response = await fetch('https://public-api-v2.bags.fm/api/v1/token-launch/create-token-info', {
    method: 'POST',
    headers: {
      'x-api-key': 'YOUR_API_KEY'
    },
    body: formData
  });

  // From File object
  const file = new File([imageBlob], 'token-image.png', { type: 'image/png' });
  formData.append('image', file);
  ```

  ```python Python theme={null}
  import requests

  # From file path
  files = {'image': open('/path/to/your/image.png', 'rb')}
  data = {
    'name': 'My Token',
    'symbol': 'MYTOKEN'
  }

  response = requests.post(
    'https://public-api-v2.bags.fm/api/v1/token-launch/create-token-info',
    headers={'x-api-key': 'YOUR_API_KEY'},
    files=files,
    data=data
  )

  # Don't forget to close the file
  files['image'].close()

  # Or use context manager
  with open('/path/to/your/image.png', 'rb') as f:
      files = {'image': f}
      response = requests.post(url, headers=headers, files=files, data=data)
  ```
</CodeGroup>

## Advanced Upload Examples

### Validate File Before Upload

<CodeGroup>
  ```javascript Node.js theme={null}
  function validateImageFile(file) {
    // Check file size (15MB = 15 * 1024 * 1024 bytes)
    const maxSize = 15 * 1024 * 1024;
    if (file.size > maxSize) {
      throw new Error('File size must be under 15MB');
    }
    
    // Check file type
    const allowedTypes = ['image/png', 'image/jpeg', 'image/jpg', 'image/gif', 'image/webp'];
    if (!allowedTypes.includes(file.type)) {
      throw new Error('File must be PNG, JPG, JPEG, GIF, or WebP');
    }
    
    return true;
  }

  // Usage
  try {
    validateImageFile(fileInput.files[0]);
    // Proceed with upload
  } catch (error) {
    console.error('Validation error:', error.message);
  }
  ```

  ```python Python theme={null}
  import os

  def validate_image_file(file_path):
      # Check file size (15MB)
      max_size = 15 * 1024 * 1024
      if os.path.getsize(file_path) > max_size:
          raise ValueError('File size must be under 15MB')
      
      # Check file extension
      allowed_extensions = {'.png', '.jpg', '.jpeg', '.gif', '.webp'}
      file_ext = os.path.splitext(file_path)[1].lower()
      if file_ext not in allowed_extensions:
          raise ValueError('File must be PNG, JPG, JPEG, GIF, or WebP')
      
      return True

  # Usage
  try:
      validate_image_file('/path/to/image.png')
      # Proceed with upload
  except ValueError as e:
      print(f'Validation error: {e}')
  ```
</CodeGroup>

## Error Handling

### Common Upload Errors

**File too large (413):**

```json theme={null}
{
  "success": false,
  "error": "Image file must be under 15MB"
}
```

**Invalid file type (400):**

```json theme={null}
{
  "success": false,
  "error": "Unsupported file type. Please upload PNG, JPG, JPEG, GIF, or WebP images."
}
```

**Missing file (400):**

```json theme={null}
{
  "success": false,
  "error": "Image file is required"
}
```

**Corrupted file (400):**

```json theme={null}
{
  "success": false,
  "error": "Invalid image file. Please check your file and try again."
}
```

## Best Practices

1. **Always validate files client-side** before uploading to save bandwidth and API quota
2. **Compress images** when possible to improve upload speed and user experience
3. **Show progress indicators** for better user experience during uploads
4. **Handle network interruptions** with retry logic for failed uploads
5. **Use appropriate image formats** - PNG for graphics with transparency, JPEG for photos
6. **Optimize image dimensions** - resize to appropriate dimensions before upload

<Warning>
  Uploaded images are processed and optimized by the Bags system. The final image URL may differ from your uploaded version.
</Warning>

<Tip>
  Consider implementing client-side image compression to improve upload speeds and stay within file size limits.
</Tip>
