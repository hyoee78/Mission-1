# 개발 워크스테이션 구축 미션 (macOS)

> 진행 상태: 미션 수행과 평가 피드백 보완을 완료했습니다. 공개 `hyoee78/Mission-1`에 SSH 방식으로 Push했고 VS Code GitHub 로그인을 확인했습니다. 포트 충돌 진단과 named volume 백업·복구 절차도 실제 명령으로 검증했습니다.

## 프로젝트 개요

터미널과 파일 권한, Docker 이미지와 컨테이너, 포트 연결, 바인드 마운트, 영속 볼륨을 실제 출력으로 검증하는 개발 환경 실습입니다. 웹 서비스는 NGINX Alpine 기반으로 직접 작성한 정적 페이지를 제공합니다.

## 실행 환경

| 항목 | 확인 결과 |
| --- | --- |
| OS | macOS 27.0.1 (Build 26A434), 개인 Mac |
| Shell | zsh |
| Docker CLI | 29.9.2, build a82e528 |
| Docker Desktop | 4.97.0; 엔진은 Resource Saver에서 재개했고 현재 CLI 명령이 정상 실행됨 |
| Docker Engine | 29.9.2 |
| Git | 2.54.0 (Apple Git-157); main 브랜치 저장소와 로컬 사용자 설정 완료 |
| GitHub CLI | 2.103.2; hyoee78로 인증해 Mission-1에 Push |
| VS Code | 1.144.1 (Apple Silicon); GitHub Pull Requests 확장에 `hyoee78` 로그인 확인 |

## 체크리스트

- [x] macOS 버전과 Docker/Git/VS Code 설치 상태 확인
- [x] 터미널에서 위치/목록/숨김 파일/이동/생성/복사/이름 변경/삭제
- [x] 파일 및 디렉터리 권한 확인과 변경
- [x] Docker 버전과 엔진 점검
- [x] hello-world 실행과 Ubuntu 명령 실행
- [x] 이미지/컨테이너 목록, logs, stats, stop/start, attach/exec
- [x] Dockerfile 커스텀 이미지 빌드 및 실행
- [x] 8080, 8081 호스트 포트에서 HTTP 200 응답 확인
- [x] 바인드 마운트 파일 변경 반영 확인
- [x] 컨테이너 삭제 뒤 named volume 데이터 유지 확인
- [x] 주소창과 웹 응답이 함께 보이는 브라우저 스크린샷 추가
- [x] Apple Command Line Tools 설치 후 Git 버전/로컬 설정 기록
- [x] VS Code 설치, 과제 저장소 열기, GitHub 계정 `hyoee78` 로그인 확인
- [x] 공개 Mission-1 원격 저장소 확인/연결 및 기존 이력 병합
- [x] Mission-1 인증 및 main 브랜치 Push/원격 해시 검증
- [x] SSH 공개 키 등록, SSH 인증 및 SSH 방식 원격 조회
- [x] 포트 점유 프로세스 확인 및 안전한 포트 충돌 대응 절차
- [x] named volume tar 백업 및 별도 검증 볼륨 복구
- [x] 실제 Docker 문제 해결 2건 이상 기록

## 폴더 구조

~~~text
workstation-mission/
├── .dockerignore
├── .gitignore
├── Dockerfile
├── README.md
├── site/
│   └── index.html
├── practice/
│   ├── run-docker-practice.sh
│   └── terminal-operations.log.txt
├── runtime/
│   └── bind/index.html
└── evidence/
    ├── README.md
    ├── docker-cli-status.txt
    ├── docker-practice.log.txt
    ├── docker-operations-followup.txt
    ├── git-local-status.txt
    ├── github-push-status.txt
    ├── github-ssh-status.txt
    ├── workstation-mission-data.tar.gz
    ├── browser-port-8080.jpg
    ├── vscode-github-account.jpg
    ├── vscode-github-status.txt
    └── web-8080-content.png
~~~

## 터미널 파일 관리와 권한

[터미널 실습 로그](practice/terminal-operations.log.txt)에 명령과 출력이 있습니다(2026-11-03 수행). pwd, ls -la, mkdir, cd, printf, touch, cat, cp, mv, rm과 chmod를 수행했습니다. 파일은 일반 텍스트를 소유자가 편집하고 다른 사용자는 읽도록 644로, 실습 디렉터리는 소유자만 접근하도록 700으로 바꿨습니다(변경 전 기본값 755).

절대 경로는 /Users/...처럼 루트에서 시작하고, 상대 경로는 현재 위치를 기준으로 합니다. 권한 숫자는 소유자/그룹/기타 사용자 순서이며 r=4, w=2, x=1을 더합니다. `644 = rw-r--r--`는 소유자 읽기/쓰기, 나머지 읽기이고, `755 = rwxr-xr-x`는 소유자 전체 권한, 나머지 읽기/탐색입니다. 디렉터리의 x는 해당 디렉터리 안으로 이동/탐색할 권한입니다.

## Docker 설치와 기본 점검

실행 명령과 출력 전체는 [Docker 실습 로그](evidence/docker-practice.log.txt)에 있습니다.

~~~text
$ docker --version
Docker version 29.9.2, build a82e528

$ docker info --format '{{.ServerVersion}}'
29.9.2

$ docker run --rm hello-world
Hello from Docker!
~~~

Docker Desktop 시작 화면에서 Resource Saver 상태를 확인하고 Resume를 눌렀습니다. UI에는 Engine running이 표시됐고 통합 터미널의 `docker info`가 ServerVersion 29.9.2를 반환했습니다. 명령 결과는 [Docker 실습 로그](evidence/docker-practice.log.txt)에, 초기 제한 셸의 소켓 거부와 환경 전환 설명은 [초기 점검 로그](evidence/docker-cli-status.txt)에 있습니다. `docker run --rm hello-world`는 로그에서 `[exit 0]`으로 종료했습니다.

이미지는 실행할 컨테이너의 템플릿이고, 컨테이너는 이미지로부터 만들어져 실행/정지되는 격리된 인스턴스입니다. 예를 들어 `docker build -t workstation-mission-web:1.0 .`으로 이미지를 만들고 `docker run ... workstation-mission-web:1.0`으로 컨테이너를 생성합니다. 컨테이너 안 변경은 이미지에 자동 저장되지 않으므로 이미지에 반영하려면 소스/Dockerfile을 수정해 다시 빌드합니다. `:1.0`은 이미지 버전을 구분하는 태그입니다.

## Ubuntu와 Docker 운영

Ubuntu 24.04 임시 컨테이너에서 pwd, whoami, ls -la, echo를 실행했습니다. 별도 컨테이너에서는 exec로 실행 중인 컨테이너 안에 새 명령을 실행했고, attach로 주 프로세스에 연결해 명령을 보낸 다음 Ctrl-P, Ctrl-Q로 분리했습니다. attach 후에도 컨테이너는 실행 중이었고, exec는 컨테이너의 주 프로세스를 연결하지 않고 별도 명령을 실행했습니다.

Docker 로그에는 images, ps, ps -a, logs, stats, stop/start의 실제 출력이 포함되어 있습니다. 출력은 CLI 기본 순서이며 `docker images`는 저장소/태그별 목록이고 `docker ps`는 생성 시각 기준 최신 컨테이너가 먼저 표시됩니다. 실습용 Ubuntu attach 컨테이너는 확인 후 정리했습니다.

## 커스텀 웹 서버와 포트 매핑

베이스 이미지는 nginx:alpine입니다. Dockerfile은 site/index.html을 NGINX 웹 루트로 복사하고 포트 80을 공개하며 내부 HTTP healthcheck를 설정합니다. 커스텀 목적은 직접 작성한 페이지를 기본 NGINX 이미지에서 제공하고 서비스 상태를 확인하는 것입니다.

이미지를 workstation-mission-web:1.0으로 빌드하고 두 컨테이너를 실행했습니다.

~~~text
$ docker run -d --name workstation-web-8080 -p 8080:80 workstation-mission-web:1.0
$ curl -i http://localhost:8080
HTTP/1.1 200 OK

$ docker run -d --name workstation-web-8081 -p 8081:80 workstation-mission-web:1.0
$ curl -i http://localhost:8081
HTTP/1.1 200 OK
~~~

Docker 실습 로그에는 두 응답의 전체 헤더와 HTML, images, ps, logs, stats 결과가 있습니다. 컨테이너는 자체 네트워크 네임스페이스의 인터페이스와 포트를 사용하므로 호스트의 `localhost:8080`에서 컨테이너 포트 80으로 직접 접근할 수 없습니다. `-p 8080:80`은 호스트 8080 요청을 해당 컨테이너의 80으로 전달하도록 Docker가 연결을 설정합니다. 테스트는 `curl -i`로 HTTP 헤더와 본문을 확인했고 브라우저는 Firefox입니다. 브라우저 캡처는 [주소창 포함 접속 화면](evidence/browser-port-8080.jpg) 및 [페이지 화면](evidence/web-8080-content.png)입니다.

## 바인드 마운트와 영속 볼륨

바인드 마운트는 runtime/bind/index.html을 컨테이너의 /usr/share/nginx/html/index.html에 연결했습니다. 호스트 파일을 “bind mount version one”에서 “bind mount version two”로 바꾼 뒤 같은 URL에서 새 내용이 보이는 것을 확인했습니다. 첫 요청은 서버가 준비되기 전에 보내 연결 오류가 났고, 2초 기다린 뒤 재확인하여 두 버전 응답을 모두 확인했습니다.

Named volume workstation-mission-data에 Ubuntu 컨테이너를 연결해 /data/check.txt에 persistent-data를 썼습니다. 작성한 컨테이너를 삭제한 뒤 새 임시 컨테이너로 같은 볼륨을 연결했고 파일 내용이 유지되는 것을 확인했습니다. macOS Docker Desktop의 named volume은 Docker 관리 Linux VM 내부에 저장되므로 고정 호스트 경로 대신 helper 컨테이너로 읽고 백업합니다. [추가 운영 로그](evidence/docker-operations-followup.txt)는 tar 백업을 만든 뒤 별도 검증 볼륨에 복구해 같은 내용을 확인하며, 아카이브는 [workstation-mission-data.tar.gz](evidence/workstation-mission-data.tar.gz)입니다.

~~~text
$ docker exec workstation-volume-one sh -c 'echo persistent-data > /data/check.txt && cat /data/check.txt'
persistent-data
$ docker rm -f workstation-volume-one
workstation-volume-one
$ docker run --rm -v workstation-mission-data:/data ubuntu:24.04 cat /data/check.txt
persistent-data
~~~

백업은 프로젝트 루트에서 아래처럼 tar 아카이브로 내보낼 수 있습니다. 복구할 때는 새 볼륨에 압축을 풉니다.

~~~sh
docker run --rm -v workstation-mission-data:/source:ro -v "$PWD/evidence:/backup" alpine:3.20 \
  sh -c 'tar czf /backup/workstation-mission-data.tar.gz -C /source .'
docker volume create workstation-mission-restore-check
docker run --rm -v workstation-mission-restore-check:/restore -v "$PWD/evidence:/backup:ro" alpine:3.20 \
  sh -c 'tar xzf /backup/workstation-mission-data.tar.gz -C /restore && cat /restore/check.txt'
# 검증 결과: persistent-data
docker volume rm workstation-mission-restore-check
~~~

## 트러블슈팅

1. **Docker Desktop Resource Saver** — Docker Desktop이 Resource Saver 상태여서 엔진 CLI 접근이 되지 않았습니다. 앱에서 Resume를 선택하고 UI의 Engine running 표시를 확인한 뒤 `docker info`가 서버 버전 29.9.2를 반환하는 것으로 해결을 검증했습니다. 초기 오류는 [docker-cli-status.txt](evidence/docker-cli-status.txt), 해결 후 출력은 [docker-practice.log.txt](evidence/docker-practice.log.txt)에 있습니다.
2. **컨테이너 이름 중복** — 격리된 실습 컨테이너를 같은 workstation-name-conflict 이름으로 두 번 실행해 Conflict 오류를 재현했습니다. 첫 컨테이너를 제거하고 같은 이름으로 다시 실행해 해결을 확인했습니다. 관련 명령과 출력은 [docker-practice.log.txt](evidence/docker-practice.log.txt)에 있습니다.
3. **바인드 마운트 초기 접속 시점** — 컨테이너를 시작하자마자 보낸 첫 curl은 NGINX 준비 전이라 exit 56을 반환했습니다. 2초 대기 후 요청하니 version one이 반환됐고, 호스트 파일을 version two로 수정한 뒤 동일한 URL에서 version two를 확인했습니다. 요청/응답은 [docker-practice.log.txt](evidence/docker-practice.log.txt)에 있습니다.
4. **호스트 포트 점유 확인** — 아래 순서로 PID/리스너와 컨테이너 포트를 대조합니다. 실습 중 8080은 Docker Desktop이 점유했고 8081에는 리스너가 없었습니다. 출력은 [추가 운영 로그](evidence/docker-operations-followup.txt)에 있습니다.

~~~sh
lsof -nP -iTCP:8080 -sTCP:LISTEN
ps -p <PID> -o pid=,comm=
docker ps --filter publish=8080 --format '{{.Names}} {{.Ports}}'
# 내 컨테이너라고 확인된 경우에만 중지: docker stop <컨테이너명>
# 그 외에는 사용 가능한 호스트 포트 선택: docker run -p 8082:80 ...
~~~

알 수 없는 프로세스는 강제 종료하지 않습니다.

## Git, GitHub, VS Code

Apple Command Line Tools를 설치했고 git version 2.54.0 (Apple Git-157)을 확인했습니다. 과제 폴더에 main 브랜치로 별도 저장소를 초기화하고 Git 사용자 이름과 이메일을 로컬 설정에 저장했습니다. `git config --list --show-origin`의 이메일은 증거 파일에서 마스킹했습니다. 초기 저장소 인증/Push에는 HTTPS와 GitHub CLI를 사용했고, SSH 키 인증 성공 후 현재 원격은 `git@github.com:hyoee78/Mission-1.git`입니다. 원격의 기존 README 초기 커밋을 보존했고 최신 변경은 SSH로 Push했습니다. VS Code 1.144.1과 GitHub 확장에서 계정 `hyoee78` 로그인을 확인했습니다. [HTTPS 초기 Push 기록](evidence/github-push-status.txt), [현재 SSH 원격 검증](evidence/github-ssh-status.txt), [VS Code 화면 증거](evidence/vscode-github-account.jpg)를 참고하세요. 비밀번호/토큰/인증 코드는 문서나 로그에 기록하지 않습니다.

### SSH 푸시 보너스

ED25519 키 쌍을 Mac의 `~/.ssh/id_ed25519_github`에 만들고 개인 키는 로컬에 보관했습니다. GitHub 계정에는 공개 키만 등록했습니다. SSH config에서 키체인 연동(`UseKeychain`, `AddKeysToAgent`)을 설정하고 `ssh-add --apple-use-keychain`으로 에이전트에 추가했습니다. `ssh -T git@github.com`에서 `hyoee78` 인증 성공 메시지를 확인한 뒤 저장소 원격을 `git@github.com:hyoee78/Mission-1.git`로 변경했습니다. SSH를 통한 `git ls-remote`가 성공했고 원격 `main` 해시가 로컬 HEAD와 일치합니다. 명령과 출력은 [SSH 검증 기록](evidence/github-ssh-status.txt)을 참고하세요. 개인 키와 암호는 저장소에 포함하지 않았습니다.

## 재현과 증거

폴더는 역할별로 나눴습니다. `site/`는 이미지에 복사할 웹 원본, `runtime/`은 bind mount로 반영할 호스트 파일, `practice/`는 실행 스크립트와 터미널 이력, `evidence/`는 검증 결과와 제출 캡처만 담습니다. Docker 절차는 [실습 스크립트](practice/run-docker-practice.sh)의 위→아래 순서로 진행하고 [전체 명령/출력 로그](evidence/docker-practice.log.txt)를 확인합니다. 실행은 대략 2–5분으로 예상되며 첫 이미지 다운로드가 있으면 네트워크 속도에 따라 더 걸립니다. 스크립트는 이름을 지정한 과제 컨테이너와 `workstation-mission-data` 볼륨을 만듭니다. bind mount의 왼쪽은 현재 프로젝트 경로인 호스트 `$PWD/runtime/bind`, 오른쪽은 앱이 파일을 읽는 컨테이너의 `/usr/share/nginx/html`입니다. 프로젝트 루트에서 실행하면 호스트 절대 경로가 자동 산출되어 계정별 경로를 하드코딩하지 않습니다. 추가 상태는 [evidence 체크리스트](evidence/README.md)에서 확인하세요.
