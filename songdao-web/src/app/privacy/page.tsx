import AppShell from "@/components/AppShell";
import { AppBentoCard } from "@/components/ui";

export default function PrivacyPage() {
  return (
    <AppShell>
      <div>
        <h1 className="font-serif text-2xl font-bold text-text-primary">Chính sách quyền riêng tư</h1>
        <p className="mt-1 text-sm text-text-secondary">Bản web beta của Sống Đạo ưu tiên dữ liệu riêng tư và local-first.</p>
      </div>

      <AppBentoCard accentColor="#1F7A64">
        <h2 className="font-serif text-lg font-bold text-text-primary">Dữ liệu lưu trên thiết bị</h2>
        <p className="mt-2 text-sm leading-relaxed text-text-secondary">
          Lịch sử hoàn thành, ghi chú riêng và cài đặt được lưu trong trình duyệt trên thiết bị này. Sống Đạo không yêu cầu tài khoản và không tải ghi chú của bạn lên máy chủ.
        </p>
      </AppBentoCard>

      <AppBentoCard>
        <h2 className="font-serif text-lg font-bold text-text-primary">Sao lưu do bạn kiểm soát</h2>
        <p className="mt-2 text-sm leading-relaxed text-text-secondary">
          Bạn có thể xuất tệp sao lưu trong Cài đặt. Tệp này nằm trên thiết bị của bạn; chỉ nhập lại khi bạn muốn khôi phục lịch sử thực hành.
        </p>
      </AppBentoCard>

      <AppBentoCard>
        <h2 className="font-serif text-lg font-bold text-text-primary">Đo lường tối thiểu</h2>
        <p className="mt-2 text-sm leading-relaxed text-text-secondary">
          Nếu bản beta bật đo lường, ứng dụng chỉ gửi sự kiện tổng hợp như mở app, hoàn thành hành động hoặc xuất dữ liệu. Nội dung ghi chú, chi tiết thực hành, vị trí chính xác và danh tính cá nhân không được gửi.
        </p>
      </AppBentoCard>
    </AppShell>
  );
}
