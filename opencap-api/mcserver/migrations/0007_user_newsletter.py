# Generated by Django 3.1.4 on 2022-07-27 16:36

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('mcserver', '0006_auto_20220725_2341'),
    ]

    operations = [
        migrations.AddField(
            model_name='user',
            name='newsletter',
            field=models.BooleanField(default=True),
        ),
    ]
