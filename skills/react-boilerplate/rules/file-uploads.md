# file-uploads

## Use When

- Adding avatar, document, image, video, import, export, or attachment uploads.
- Handling file preview, progress, drag and drop, validation, or retry.
- Integrating an upload API, signed URL flow, or storage SDK.

## Rule

Treat uploads as mutations. Validate file type and size on the client for user
feedback, and require server-side validation for security. Keep selected files
out of global stores unless a multi-step flow needs them.

## Prefer

```tsx
const maxAvatarSize = 2 * 1024 * 1024;
const allowedAvatarTypes = new Set(["image/jpeg", "image/png", "image/webp"]);

function validateAvatar(file: File) {
  if (!allowedAvatarTypes.has(file.type)) {
    return "Use a JPG, PNG, or WebP image.";
  }

  if (file.size > maxAvatarSize) {
    return "Use an image smaller than 2 MB.";
  }

  return null;
}

export function AvatarUpload() {
  const uploadAvatar = useUploadAvatar();

  async function onFileChange(file: File | null) {
    if (!file) {
      return;
    }

    const error = validateAvatar(file);

    if (error) {
      toast.error(error);
      return;
    }

    uploadAvatar.mutate({ file });
  }

  return (
    <input
      aria-label="Upload avatar"
      type="file"
      accept="image/jpeg,image/png,image/webp"
      onChange={(event) => onFileChange(event.target.files?.[0] ?? null)}
    />
  );
}
```

## Avoid

```tsx
uploadAvatar.mutate({ file: event.target.files![0] });
```

## Notes

- Use `FormData` or a signed upload URL according to the existing backend
  pattern.
- Show progress when uploads can take noticeable time.
- Revoke preview object URLs when they are no longer needed.
- Disable submit controls while upload mutations are pending.
- Never rely on client-side file validation alone.
- Keep storage paths, ownership, virus scanning, and authorization on the server
  side.
