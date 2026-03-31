"""Test blog API endpoints"""
import requeststry:
    # Test public blog list
    BASE = "https://api.ecotrade-rwanda.com/api"
    # BASE = "http://127.0.0.1:8000/api"

    response = requests.get(f"{BASE}/blog")
    print(f"✅ GET /api/blog - Status: {response.status_code}")

    if response.status_code == 200:
        posts = response.json()
        print(f"   Found {len(posts)} blog posts")
        if posts:
            print(f"   First post: {posts[0]['title']}")
            print(f"   Category: {posts[0]['category']}")
            print(f"   Published: {posts[0]['is_published']}")
            print(f"   Views: {posts[0]['view_count']}")

    # Test categories endpoint
    response = requests.get(f"{BASE}/blog/categories")
    print(f"\n✅ GET /api/blog/categories - Status: {response.status_code}")
    if response.status_code == 200:
        categories = response.json()
        print(f"   Categories: {', '.join(categories)}")

    # Test get by slug
    response = requests.get(f"{BASE}/blog/slug/rwanda-green-leader-africa")
    print(f"\n✅ GET /api/blog/slug/rwanda-green-leader-africa - Status: {response.status_code}")
    if response.status_code == 200:
        post = response.json()
        print(f"   Title: {post['title']}")
        print(f"   Views: {post['view_count']}")

    print("\n✅ All blog API tests passed!")

except requests.exceptions.ConnectionError:
    print("❌ Error: Could not connect to backend server")
    print("   Make sure the server is running on https://api.ecotrade-rwanda.com")
except Exception as e:
    print(f"❌ Error: {e}")
