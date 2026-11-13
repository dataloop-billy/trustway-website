#!/usr/bin/env bash
# 푸시 전 점검 스크립트: bash check.sh
cd "$(dirname "$0")" || exit 1
fail=0
ok()   { echo "OK   $1"; }
bad()  { echo "FAIL $1"; fail=1; }

[ "$(cat CNAME 2>/dev/null | tr -d '\r\n ')" = "www.trustway.co.kr" ] && ok "CNAME 이 www.trustway.co.kr 입니다" || bad "CNAME 파일이 없거나 값이 다릅니다 (www.trustway.co.kr 이어야 함)"
[ -f .nojekyll ] && ok ".nojekyll 파일이 있습니다" || bad ".nojekyll 파일이 없습니다"
[ -f index.html ] && ok "index.html 이 있습니다" || { bad "index.html 이 없습니다"; exit 1; }

grep -q 'script.google.com/macros/s/AKfycbxJZXtsyFT1_CAJi8zPLvJfVgGxTj5aaDfBW0Kf7IL8s0zFw-COaR7ZxqDyZbePe0RVVw/exec' index.html \
  && ok "신청폼 전송 주소가 그대로입니다" || bad "신청폼 전송 주소가 바뀌었거나 없습니다 (신청 접수가 멈춥니다)"
grep -q 'id="recruit-form"' index.html && ok "신청폼(recruit-form)이 있습니다" || bad "신청폼(recruit-form)이 없습니다"
for id in name phone experience affiliation email message privacyConsent website; do
  grep -q "id=\"$id\"" index.html && ok "입력칸 id=\"$id\" 있음" || bad "입력칸 id=\"$id\" 가 없습니다 (접수 항목이 깨집니다)"
done
for n in interests preferredTime; do
  grep -q "name=\"$n\"" index.html && ok "입력칸 name=\"$n\" 있음" || bad "입력칸 name=\"$n\" 가 없습니다"
done
grep -q '<title>트러스트웨이 홈페이지</title>' index.html && ok "페이지 제목이 '트러스트웨이 홈페이지' 입니다" || bad "페이지 제목이 '트러스트웨이 홈페이지' 가 아닙니다"
grep -q 'preview-bar' index.html && bad "미리보기 안내(preview-bar)가 남아 있습니다" || ok "미리보기 안내가 없습니다"
[ "$(wc -c < index.html)" -lt 15000000 ] && ok "index.html 크기가 15MB 미만입니다" || bad "index.html 이 너무 큽니다 (이미지는 assets/ 폴더 파일로 분리하세요)"

echo
[ $fail -eq 0 ] && echo "모든 점검 통과: 푸시해도 됩니다." || echo "실패 항목이 있습니다: 고친 뒤 다시 실행하세요. 푸시하지 마세요."
exit $fail
