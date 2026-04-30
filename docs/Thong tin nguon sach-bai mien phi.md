<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

# Tìm kiếm thông tin nguồn sách kinh thánh, các bài đọc, miễn phí, để tôi có thể sử dụng trong phát triển ứng dụng Sống Đạo

Có một số nguồn Kinh Thánh Công giáo và bài đọc miễn phí phù hợp cho app Sống Đạo, ưu tiên local-first như PRD gợi ý: dùng references trước, tránh full text bản quyền. Các API và trang web dưới đây hỗ trợ tiếng Việt, dễ tích hợp offline qua download hoặc JSON.[^1][^2][^3]

## Nguồn Kinh Thánh Tiếng Việt Miễn Phí

- **Bible API miễn phí không giới hạn**: AO Lab cung cấp JSON API với >1000 bản dịch, bao gồm tiếng Việt (VIE1925, BD2011), không key, không limit, MIT license cho commercial use. Tải verses/chapters dễ dàng cho app.[^3]
- **Bible.com (YouVersion)**: Bản Kinh Thánh Tiếng Việt 1925 (VIE1925) và các bản khác miễn phí download, API cơ bản cho verses. Phù hợp offline sau khi cache.[^4]
- **vcatholic.myartsonline.com**: Kinh Thánh Công giáo phiên bản CGKPV (Cá Các Giờ Kinh Phụng Vụ), online miễn phí, có thể scrape hoặc dùng làm reference.[^5]
- **GitHub Bible API**: Hỗ trợ đa ngôn ngữ, nhanh và free, dễ tích hợp Flutter.[^2]


## Bài Đọc Hàng Ngày (Lectionary)

- **USCCB Readings**: Free RSS/widget cho daily readings (English), nhưng full app cần license. Dùng references (citation) cho MVP như PRD khuyên.[^6][^1]
- **Catholic Gallery Widget**: Free Mass readings widget (English/Tamil), customize cho tiếng Việt qua API tương tự.[^7]
- **Apps tham khảo**: Kinh Thánh Công Giáo 4.0 (Google Play/App Store) dùng nội dung free, cập nhật daily readings – nghiên cứu source code hoặc liên hệ.[^8][^9]


## Lời Khuyên Tích Hợp App

PRD Sống Đạo nhấn mạnh MVP dùng "reading references, short public-domain excerpts" để tránh license phức tạp (ví dụ USCCB yêu cầu phí cho digital). Bắt đầu với Bible API cho verses offline, generate daily actions từ liturgical calendar seed. Cập nhật content packs JSON/SQLite cho readings refs.[^1]
<span style="display:none">[^10][^11][^12]</span>

<div align="center">⁂</div>

[^1]: Song-Dao-A-Local-First-Catholic-Daily-Practice-App-PRD-and-Flutter-Architecture.md

[^2]: https://github.com/wldeh/bible-api

[^3]: https://faith.tools/app/288-free-use-bible-api

[^4]: https://www.bible.com/vi/versions/193-vie1925-kinh-thánh-tiếng-việt-1925

[^5]: http://vcatholic.myartsonline.com/bible/cgkpv/index.html

[^6]: http://www.opensourcecatholic.com/2011/open-access-to-the-catholic-bible-and-catechism-nab-nabre-and-ccc

[^7]: https://www.catholicgallery.org/widget/free-mass-readings-widget-for-your-website-or-blog/

[^8]: https://play.google.com/store/apps/details?id=com.giesumaria.net\&hl=en_IE

[^9]: https://apps.apple.com/vn/app/kinh-thánh-công-giáo-4-0/id6443822101

[^10]: s_ng_o_project_brief.md

[^11]: https://apps.apple.com/vn/app/kinh-thánh-vietnam-holy-bible/id1484208715?l=vi

[^12]: https://catholic-daily-missal-readings-free-app.vi.softonic.com/android

