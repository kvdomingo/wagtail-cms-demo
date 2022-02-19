from django.contrib import admin
from django.urls import include, path
from django.conf import settings
from django.conf.urls.static import static
from demosite.urls import api_router

urlpatterns = [
    path("admin/", admin.site.urls),
    path("cms/", include("wagtail.admin.urls")),
    path("documents/", include("wagtail.documents.urls")),
    path("pages/", include("wagtail.core.urls")),
    path("api/", api_router.urls),
    *static(settings.STATIC_URL, document_root=settings.STATIC_ROOT),
    *static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT),
]
