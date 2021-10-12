# CKA 환경 자동접속

1.  CONSOLE을 만들어서 ssh 키 생성하여 web서버로 오픈
2.  NODE 생성되면서, ssh 키 적용하고 각 master와 worker 패키지 설치 (node_ssh.. sh 스크립트에 있음)
3. CONSOLE생성 시 start_shell에서 다운로드 받은 access_multi 실행.
    - 그전에 ssh 연결되는지, k8s 생성되었는지 체크.
