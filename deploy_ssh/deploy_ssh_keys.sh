#!/bin/bash

# SSH 키 자동 배포 스크립트 (비밀번호 포함)

# 서버 목록 파일 (호스트, 사용자, 비밀번호 정보를 포함)
SERVER_LIST="servers_with_passwords.txt"

# 로컬 SSH 키 파일 (기본값: ~/.ssh/id_rsa.pub)
SSH_KEY="$HOME/.ssh/id_rsa.pub"

# SSH 키 생성 함수
generate_ssh_key() {
    if [ ! -f "$SSH_KEY" ]; then
        echo "SSH 키가 없습니다. 새로 생성합니다..."
        ssh-keygen -t rsa -b 4096 -N "" -f "${SSH_KEY%.*}" || { echo "SSH 키 생성 실패!"; exit 1; }
    else
        echo "SSH 키가 이미 존재합니다: $SSH_KEY"
    fi
}

# 서버로 SSH 키 복사 함수 (비밀번호 포함)
copy_ssh_key() {
    local user_host="$1"
    local password="$2"

    echo "[$user_host]에 SSH 키를 복사합니다..."
    sshpass -p "$password" ssh-copy-id -o StrictHostKeyChecking=no -i "$SSH_KEY" "$user_host" \
        || echo "[$user_host] 키 복사 실패!"
}

# 서버 목록 읽기 및 키 배포
deploy_keys() {
    if [ ! -f "$SERVER_LIST" ]; then
        echo "서버 목록 파일($SERVER_LIST)이 존재하지 않습니다!"
        exit 1
    fi

    while IFS=, read -r user_host password || [ -n "$user_host" ]; do
        if [[ "$user_host" =~ ^#.*$ ]] || [[ -z "$user_host" ]]; then
            # 주석(#)이나 빈 줄은 건너뜀
            continue
        fi
        copy_ssh_key "$user_host" "$password"
    done < "$SERVER_LIST"
}

# 메인 실행 흐름
main() {
    echo "SSH 키 자동 배포를 시작합니다..."
    generate_ssh_key
    deploy_keys
    echo "SSH 키 배포가 완료되었습니다!"
}

# 스크립트 실행
main

