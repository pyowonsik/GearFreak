# Universal Links / App Links 구현 가이드

이 문서는 Universal Links (iOS)와 App Links (Android)를 구현하는 전체 과정을 설명합니다.

## 📋 목차

1. [개요](#개요)
2. [Flutter 앱 설정](#flutter-앱-설정)
3. [인프라 배포](#인프라-배포)
4. [인증 파일 업로드](#인증-파일-업로드)
5. [테스트](#테스트)
6. [문제 해결](#문제-해결)

---

## 개요

### Universal Links / App Links란?

- **Universal Links (iOS)**: `https://` 스킴을 사용하는 딥링크
- **App Links (Android)**: `https://` 스킴을 사용하는 딥링크
- **장점**:
  - Custom Scheme보다 신뢰도 높음
  - 브라우저에서도 앱으로 자동 연결
  - 사용자 경험 향상

### 현재 구현 상태

- ✅ Custom Scheme 딥링크 구현 완료 (`gearfreak://`)
- ✅ Universal Links/App Links Flutter 설정 완료
- ✅ 인프라 배포 완료 (Route53 + CloudFront + S3)
- ✅ 인증 파일 업로드 완료

---

## Flutter 앱 설정

### iOS 설정

**파일**: `gear_freak_flutter/ios/Runner/Runner.entitlements`

```xml
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:gear-freaks.com</string>
</array>
```

### Android 설정

**파일**: `gear_freak_flutter/android/app/src/main/AndroidManifest.xml`

```xml
<!-- App Links (Universal Links) -->
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:scheme="https"
        android:host="gear-freaks.com" />
</intent-filter>
```

### 공유 기능

**파일**: `gear_freak_flutter/lib/common/utils/share_utils.dart`

```dart
final deepLinkUrl = 'https://gear-freaks.com/product/$productId';
```

---

## 인프라 배포

### 배포된 리소스

1. **SSL 인증서** (ACM)

   - CloudFront용 인증서 (us-east-1)
   - DNS 검증 레코드

2. **CloudFront Distribution** (인증 파일용)

   - S3 origin
   - `.well-known/*` 경로 서빙
   - `/product/*` 경로 fallback 페이지 처리

3. **Route53 DNS 레코드**

   - `gear-freaks.com` → CloudFront

4. **S3 버킷** (이미 생성됨)
   - `gear-freak-public-storage-3059875`

### Terraform 배포

```bash
cd gear_freak_server/deploy/aws/terraform

# Universal Links/App Links 관련 리소스만 배포
terraform apply \
  -target=aws_acm_certificate.cloudfront \
  -target=aws_acm_certificate_validation.cloudfront \
  -target=aws_route53_record.certificate_validation_cloudfront \
  -target=aws_cloudfront_distribution.well_known \
  -target=aws_route53_record.well_known \
  -auto-approve
```

**배포 시간**: 약 15-20분 (SSL 인증서 발급 + CloudFront 배포)

---

## 인증 파일 업로드

### 인증 파일 준비

**파일 1**: `apple-app-site-association` (확장자 없음)

- 경로: `.well-known/apple-app-site-association`
- Content-Type: `application/json`

**파일 2**: `assetlinks.json`

- 경로: `.well-known/assetlinks.json`
- Content-Type: `application/json`

### S3에 업로드

#### AWS CLI 사용

```bash
# apple-app-site-association 업로드
aws s3 cp \
  gear_freak_server/public/.well-known/apple-app-site-association \
  s3://gear-freak-public-storage-3059875/.well-known/apple-app-site-association \
  --content-type "application/json" \
  --acl public-read

# assetlinks.json 업로드
aws s3 cp \
  gear_freak_server/public/.well-known/assetlinks.json \
  s3://gear-freak-public-storage-3059875/.well-known/assetlinks.json \
  --content-type "application/json" \
  --acl public-read

# fallback 페이지 업로드
aws s3 cp \
  gear_freak_server/public/product/index.html \
  s3://gear-freak-public-storage-3059875/product/index.html \
  --content-type "text/html" \
  --acl public-read
```

#### AWS 콘솔 사용

1. S3 콘솔 → `gear-freak-public-storage-3059875` 버킷
2. `.well-known/` 폴더 생성
3. 파일 업로드:
   - `apple-app-site-association` (확장자 없음)
   - `assetlinks.json`
4. 각 파일의 메타데이터에서 Content-Type을 `application/json`으로 설정
5. 권한에서 "Public read" 체크

---

## 테스트

### 1. 인증 파일 접근 테스트

#### iOS 인증 파일

```bash
curl -I https://gear-freaks.com/.well-known/apple-app-site-association
```

**예상 결과**:

```
HTTP/2 200
content-type: application/json
```

#### Android 인증 파일

```bash
curl -I https://gear-freaks.com/.well-known/assetlinks.json
```

**예상 결과**:

```
HTTP/2 200
content-type: application/json
```

### 2. Fallback 페이지 테스트

```bash
curl https://gear-freaks.com/product/123
```

앱이 설치되지 않은 경우 HTML 페이지가 표시되어야 합니다.

### 3. 앱에서 테스트

1. **iOS**:

   - Safari에서 `https://gear-freaks.com/product/123` 링크 클릭
   - 앱이 자동으로 열리고 상품 페이지로 이동하는지 확인

2. **Android**:
   - Chrome에서 `https://gear-freaks.com/product/123` 링크 클릭
   - 앱이 자동으로 열리고 상품 페이지로 이동하는지 확인

---

## 문제 해결

### SSL 인증서 검증 실패

**문제**: 인증서 검증이 완료되지 않음

**해결**:

1. Route53 DNS 레코드 확인
2. DNS 전파 대기 (최대 48시간, 보통 몇 시간)
3. 인증서 상태 확인:
   ```bash
   aws acm describe-certificate \
     --certificate-arn <CERTIFICATE_ARN> \
     --region us-east-1
   ```

### CloudFront 404 오류

**문제**: `https://gear-freaks.com/.well-known/...` 접근 시 404

**해결**:

1. S3에 파일이 올바르게 업로드되었는지 확인
2. 파일 경로 확인 (`.well-known/apple-app-site-association`)
3. CloudFront 캐시 무효화:
   ```bash
   aws cloudfront create-invalidation \
     --distribution-id <DISTRIBUTION_ID> \
     --paths "/.well-known/*"
   ```

### Content-Type 오류

**문제**: 파일이 다운로드되거나 잘못된 Content-Type

**해결**:

1. S3에서 파일 메타데이터 확인
2. Content-Type을 `application/json`으로 설정
3. CloudFront 캐시 무효화

### iOS Universal Links가 작동하지 않음

**문제**: 앱이 열리지 않고 JSON 파일이 표시됨

**해결**:

1. Associated Domains 활성화 확인 (Xcode → Signing & Capabilities)
2. 앱 재설치 (Universal Links는 앱 설치 시 검증됨)
3. Safari에서 테스트 (KakaoTalk 등 인앱 브라우저는 제한적)

### 카카오톡 인앱 브라우저에서 딥링크가 작동하지 않음

**문제**: 카카오톡에서 딥링크 접속 시 앱이 열리지 않고 fallback 페이지만 표시됨

**원인**:

- 카카오톡, 페이스북, 인스타그램 등 인앱 브라우저는 Universal Links/App Links를 지원하지 않음
- 인앱 브라우저에서 링크 클릭 시 WebView로 열림
- CloudFront의 404/403 → index.html 리다이렉트로 인해 fallback 페이지가 표시됨

**해결 방법**:

#### 1. Fallback 페이지에서 User-Agent 감지 및 커스텀 스킴 사용

**파일**: `gear_freak_server/public/product/index.html`

```javascript
// User-Agent 감지
function detectEnvironment() {
  const userAgent = navigator.userAgent.toLowerCase();
  return {
    isKakaoTalk: userAgent.includes('kakaotalk'),
    isFacebook: userAgent.includes('fban') || userAgent.includes('fbav'),
    isInstagram: userAgent.includes('instagram'),
    isLine: userAgent.includes('line'),
    isAndroid: /android/i.test(userAgent),
    isIOS: /iphone|ipad|ipod/i.test(userAgent),
    isInAppBrowser:
      userAgent.includes('kakaotalk') ||
      userAgent.includes('fban') ||
      userAgent.includes('fbav') ||
      userAgent.includes('instagram') ||
      userAgent.includes('line'),
  };
}

// 3단계 폴백 전략
function handleDeepLink(productId, env) {
  const universalLink = `https://gear-freaks.com/product/${productId}`;
  const customScheme = `gearfreak://product/${productId}`;

  if (env.isInAppBrowser) {
    // 1단계: 커스텀 스킴 시도
    window.location.href = customScheme;

    // 2단계: 카카오톡인 경우 외부 브라우저로 열기 시도 (2초 후)
    if (env.isKakaoTalk) {
      setTimeout(() => {
        window.location.href =
          'kakaotalk://web/openExternal?url=' +
          encodeURIComponent(universalLink);
      }, 2000);
    }

    // 3단계: 스토어로 이동 (5초 후)
    setTimeout(() => {
      redirectToStore(env);
    }, 5000);
  }
}
```

#### 2. 커스텀 스킴 설정 확인

**Android**: `AndroidManifest.xml`

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="gearfreak" />
</intent-filter>
```

**iOS**: `Info.plist`

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>gearfreak</string>
        </array>
    </dict>
</array>
```

#### 3. 동작 방식

**일반 브라우저 (문자/메일)**:

```
https://gear-freaks.com/product/123
  ↓
Universal Links/App Links 작동
  ↓
앱 직접 실행 ✅
```

**카카오톡 인앱 브라우저**:

```
https://gear-freaks.com/product/123
  ↓
인앱 브라우저에서 열림
  ↓
404 → index.html
  ↓
1. gearfreak://product/123 시도 (커스텀 스킴)
2. (2초 후) 외부 브라우저로 열기 시도 (카카오톡만)
3. (5초 후) 스토어로 이동
```

**참고**:

- `kakaotalk://web/openExternal`은 비공식 기능이므로 언제든 막힐 수 있음
- 커스텀 스킴을 병행 사용하는 것이 더 안정적
- 일반 브라우저에서는 Universal Links/App Links가 정상 작동하므로 문제 없음

---

## 📝 체크리스트

### 완료 ✅

- [x] iOS Universal Links 설정 (Runner.entitlements)
- [x] Android App Links 설정 (AndroidManifest.xml)
- [x] 커스텀 스킴 설정 (gearfreak://)
- [x] 공유 기능 업데이트 (ShareUtils)
- [x] 인증 파일 생성
- [x] 인프라 배포 (Route53 + CloudFront + S3)
- [x] 인증 파일 업로드
- [x] Fallback 페이지 업로드 (카카오톡 인앱 브라우저 대응 포함)

---

## 💰 예상 비용

### 배포된 리소스

- **SSL 인증서**: 무료
- **CloudFront**: 데이터 전송 1TB까지 무료 (12개월)
- **Route53**: 호스팅 영역 1개 무료, 쿼리 월 100만 건까지 무료
- **S3**: 저장 5GB까지 무료

### 예상 월 비용

- **거의 무료** (프리티어 적용 시)
- CloudFront 데이터 전송량이 많아지면 과금 (GB당 약 ₩120)

---

## 📚 참고 자료

- [Apple - Universal Links](https://developer.apple.com/documentation/xcode/supporting-universal-links-in-your-app)
- [Google - App Links](https://developer.android.com/training/app-links)
- [AWS CloudFront 문서](https://docs.aws.amazon.com/cloudfront/)
- [AWS S3 문서](https://docs.aws.amazon.com/s3/)

---

---

## 🔄 CloudFront 캐시 무효화

### 언제 필요한가?

S3에 `index.html` 파일을 업로드한 후, CloudFront가 최신 버전을 즉시 반영하도록 캐시를 무효화해야 합니다.

### 명령어

```bash
aws cloudfront create-invalidation \
  --distribution-id EU0CNYU6XETK6 \
  --paths "/product/index.html"
```

### 간단한 설명

- **S3**: 원본 파일 저장소 (창고)
- **CloudFront**: 사용자에게 빠르게 제공 (매장)
- **캐시 무효화**: "매장 재고를 창고에서 새로 가져와서 갱신해주세요"

**S3의 `index.html` 변경 시 → CloudFront가 최신 `index.html`을 보게 한다**

### TTL 설정

- `.well-known/*` 파일: TTL = 0 (캐시 안 함, 무효화 불필요)
- `/product/*` 경로: TTL = 300초 (5분, 업데이트 시 무효화 필요)

---

**작성일**: 2025-11-26  
**최종 업데이트**: 2025-11-27 (카카오톡 인앱 브라우저 대응 추가)  
**프로젝트**: gear_freak
