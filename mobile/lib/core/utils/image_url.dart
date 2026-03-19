// lib/core/utils/image_url.dart
// Converts relative/absolute image paths to displayable URLs for EcoTrade Rwanda.
// Mirrors the logic in frontend/src/utils/imageUrl.ts so both platforms resolve
// the same URLs from the backend.

import '../services/api_service.dart';

/// Returns the bare server root (e.g. "http://10.0.2.2:8000") by stripping "/api".
String _serverBase() => ApiService.baseUrl.replaceAll('/api', '');

/// Converts any image path/URL to an absolute HTTPS/HTTP URL.
///
/// Handles:
/// - `null` / empty → returns empty string (let [errorBuilder] show the icon)
/// - Already absolute (`http://` / `https://`) → returned as-is
///   (covers Supabase storage URLs, CDN links, etc.)
/// - `/uploads/…` → prepends backend server root
/// - Any other `/`-prefixed path → prepends server root
/// - Bare filename / unknown → returns empty string
String getAbsoluteImageUrl(String? imageUrl) {
  if (imageUrl == null || imageUrl.isEmpty) return '';

  // Already a full URL (Supabase, CDN, or existing absolute backend URL)
  if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
    return imageUrl;
  }

  // Relative backend path – prepend server root
  if (imageUrl.startsWith('/')) {
    return '${_serverBase()}$imageUrl';
  }

  // Unknown format – return empty so the errorBuilder takes over
  return '';
}

/// Returns the first image URL from [photos], or empty string if none.
String getFirstImageUrl(List<String>? photos) {
  if (photos == null || photos.isEmpty) return '';
  return getAbsoluteImageUrl(photos.first);
}

/// Returns all images in [photos] as absolute URLs (empty strings filtered out).
List<String> getAbsoluteImageUrls(List<String>? photos) {
  if (photos == null || photos.isEmpty) return [];
  return photos
      .map(getAbsoluteImageUrl)
      .where((u) => u.isNotEmpty)
      .toList();
}
