from django.contrib import admin
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

from tasks.views import TaskViewSet, api_register,current_user  # ✅ Only API views

# DRF Router
router = DefaultRouter()
router.register(r'tasks', TaskViewSet, basename='tasks')

urlpatterns = [
    path('admin/', admin.site.urls),

    # ---- API Auth ----
    path('api/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),

    # ---- API Register ----
    path('api/register/', api_register, name='api_register'),

    # ---- API Router ----
    path('api/', include(router.urls)),
    path('api/user/', current_user, name='current-user'),
]
