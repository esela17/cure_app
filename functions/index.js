// استدعاء الوظائف الحديثة من v2
const { onDocumentCreated, onDocumentUpdated, onDocumentDeleted } = require('firebase-functions/v2/firestore');

// استدعاء Firebase Admin
const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');

// تهيئة Firebase Admin
initializeApp();
const db = getFirestore();
const messaging = getMessaging();

// 🟢 1. عند إنشاء مستند جديد في requests/
exports.onRequestCreated = onDocumentCreated('requests/{requestId}', async (event) => {
  const requestData = event.data.data();
  const requestId = event.params.requestId;

  console.log('✅ تم إنشاء طلب جديد:', requestId, requestData);

  // إرسال إشعار (مثال فقط)
  const payload = {
    notification: {
      title: 'طلب جديد',
      body: `تم إنشاء طلب رقم ${requestId}`
    },
    token: requestData.fcmToken || '' // تأكد إن عندك fcmToken داخل المستند
  };

  try {
    if (payload.token) {
      const response = await messaging.send(payload);
      console.log('🚀 إشعار تم إرساله:', response);
    } else {
      console.log('⚠️ لا يوجد FCM Token لإرسال الإشعار');
    }
  } catch (error) {
    console.error('❌ فشل في إرسال الإشعار:', error);
  }

  return;
});

// 🟡 2. عند تعديل مستند
exports.onRequestUpdated = onDocumentUpdated('requests/{requestId}', (event) => {
  const before = event.data.before.data();
  const after = event.data.after.data();
  const requestId = event.params.requestId;

  console.log('✏️ تم تعديل الطلب:', requestId);
  console.log('من:', before);
  console.log('إلى:', after);

  return;
});

// 🔴 3. عند حذف مستند
exports.onRequestDeleted = onDocumentDeleted('requests/{requestId}', (event) => {
  const deletedData = event.data.data();
  const requestId = event.params.requestId;

  console.log('🗑️ تم حذف الطلب:', requestId, deletedData);

  return;
});
