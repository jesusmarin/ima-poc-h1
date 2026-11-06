"""Offline structure checks; do not substitute for Docker/P01 execution."""
import json, pathlib, unittest
ROOT=pathlib.Path(__file__).resolve().parents[1]
class StaticSmoke(unittest.TestCase):
    def test_candidate_label_is_experimental(self):
        d=json.loads((ROOT/'config/candidates.json').read_text(encoding='utf-8'))
        self.assertIn('experimental',d['selection_status'])
    def test_compose_is_loopback(self):
        t=(ROOT/'compose.yaml').read_text(encoding='utf-8')
        self.assertIn('127.0.0.1:18080:8080',t)
        self.assertIn('KEYCLOAK_IMAGE:?',t)
    def test_no_embedded_password_in_compose(self):
        t=(ROOT/'compose.yaml').read_text(encoding='utf-8')
        self.assertIn('${KC_BOOTSTRAP_ADMIN_PASSWORD:?',t)
    def test_ignored_local_state(self):
        self.assertIn('.local/',(ROOT/'.gitignore').read_text(encoding='utf-8'))
if __name__=='__main__':unittest.main()
