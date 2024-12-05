# Generated by Django 3.1.4 on 2020-12-11 04:44

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('mcserver', '0001_initial'),
    ]

    operations = [
        migrations.RenameField(
            model_name='video',
            old_name='session',
            new_name='trial',
        ),
        migrations.CreateModel(
            name='Trial',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('session', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='mcserver.session')),
            ],
        ),
        migrations.AlterField(
            model_name='result',
            name='session',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='mcserver.trial'),
        ),
    ]