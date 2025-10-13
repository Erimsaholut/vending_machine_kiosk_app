const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const nodemailer = require("nodemailer");

initializeApp();

const mailTransport = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "buzisoftapp@gmail.com",
    pass: "ehbfhdgdxbkzzhjf",
  },
});

exports.sendRefundEmail = onDocumentCreated(
  "machines/{machineId}/profit_logs/refund_logs/{date}/{logId}",
  async (event) => {
    try {
      const data = event.data.data();
      if (!data) {
        console.error("Boş veri alındı, e-posta gönderilmiyor.");
        return;
      }

      const machineId = event.params.machineId;
      const date = event.params.date;
      const errorCode = data.errorCode || "Bilinmiyor";
      const cupType = data.cupType || "none";
      const amountTl = data.amountTl || 0;
      const amountMl = data.amountMl || 0;

      const mailOptions = {
        from: '"Buzi Kiosk" <buzisoftapp@gmail.com>',
        to: "buzisoftapp@gmail.com",
        subject: `Yeni iade kaydı (${errorCode})`,
        text: `
Yeni iade işlemi gerçekleşti:
- Makine: ${machineId}
- Tarih: ${date}
- Hata tipi: ${errorCode}
- Bardak tipi: ${cupType}
- Tutar: ${amountTl} TL
- Miktar: ${amountMl} ml
- Zaman: ${new Date().toLocaleString("tr-TR")}
        `,
      };

      console.log(`📨 E-posta gönderiliyor: ${machineId} / ${errorCode}`);
      await mailTransport.sendMail(mailOptions);
      console.log(`✅ E-posta gönderildi: ${machineId} (${errorCode})`);
    } catch (err) {
      console.error("❌ E-posta gönderim hatası:", err);
    }
  }
);