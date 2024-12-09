import requests
from django.test import TestCase


class ModelsTests(TestCase):
    def setUp(self):
        self.host = '127.0.0.1'

    def test_login(self):
        response = requests.get(f'http://{self.host}/login')
        self.assertEqual(response.status_code, 200)
        data = {"username": "admin", "password": "admin123"}
        response = requests.post(f'http://{self.host}/login', json=data)
        print(response.text)
        self.assertEqual(response.status_code, 200)
