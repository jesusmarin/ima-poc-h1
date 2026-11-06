"""P01 smoke test: metadata OIDC and JWKS reachability; NOT complete OIDC compliance."""
import argparse, datetime, hashlib, json, pathlib, sys, urllib.parse, urllib.request

def check(issuer):
    u=urllib.parse.urlsplit(issuer)
    if u.scheme != 'https' and not (u.scheme=='http' and u.hostname in ('localhost','127.0.0.1')):
        raise ValueError('Solo HTTPS o HTTP loopback local')
    base=issuer.rstrip('/')
    url=base+'/.well-known/openid-configuration'
    with urllib.request.urlopen(url,timeout=8) as r:
        doc=json.load(r)
    if doc.get('issuer') != base: raise ValueError('issuer no coincide con la URL solicitada')
    jwks=doc.get('jwks_uri')
    if not jwks: raise ValueError('jwks_uri ausente')
    dest=urllib.parse.urlsplit(jwks)
    if dest.netloc != u.netloc or dest.scheme != u.scheme:
        raise ValueError('JWKS fuera del origen del laboratorio; revision manual requerida')
    with urllib.request.urlopen(jwks,timeout=8) as r: keys=json.load(r)
    if not isinstance(keys.get('keys'),list): raise ValueError('JWKS sin keys[]')
    return {'issuer':base,'jwks_count':len(keys['keys']),'discovery_fields_present':sorted(set(doc)&{'issuer','jwks_uri','authorization_endpoint','token_endpoint','userinfo_endpoint','end_session_endpoint'}),'status':'P01_SMOKE_PASS'}

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--issuer',required=True);ap.add_argument('--out',required=True);a=ap.parse_args()
    try: data=check(a.issuer)
    except Exception as ex:
        print('FAILED:',type(ex).__name__,str(ex),file=sys.stderr);return 1
    out=pathlib.Path(a.out);out.mkdir(parents=True,exist_ok=True)
    timestamp=datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%SZ')
    run={'run_id':'RUN-H1-P01-'+timestamp,'executed_at_utc':timestamp,'candidate':'keycloak','test':'discovery-jwks-smoke','is_full_protocol_test':False,'result':data}
    payload=json.dumps(run,indent=2,ensure_ascii=False).encode('utf-8')
    target=out/(run['run_id']+'.json');target.write_bytes(payload)
    (out/(run['run_id']+'.sha256')).write_text(hashlib.sha256(payload).hexdigest()+'  '+target.name+'\n',encoding='utf-8')
    print('PASS: discovery and JWKS smoke. Evidence:',target)
    return 0
if __name__=='__main__':sys.exit(main())
