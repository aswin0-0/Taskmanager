from django.db import models
from django.contrib.auth.models import User

class Task(models.Model):
    CATEGORY_CHOICES = [
        ('Work', 'Work'),
        ('Groceries', 'Groceries'),
        ('Study', 'Study'),
        ('Personal', 'Personal'),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='tasks')
    title = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    due_date = models.DateField()
    category = models.CharField(max_length=20, choices=CATEGORY_CHOICES)
    completed = models.BooleanField(default=False)  # New field
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['due_date', 'title']  # Sorted by due date

    def __str__(self):
        return f"{self.title} ({self.category})"
