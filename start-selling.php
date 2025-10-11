<?php
session_start();
if (!empty($_SESSION['seller_id'])) {
    header('Location: seller_dashboard.php');
    exit;
}
require_once __DIR__ . '/inc/db.php';
require_once __DIR__ . '/inc/faq.php';
// Load active FAQs (limit optional, e.g., 8)
$faqs = faq_all($mysqli, true, 8);
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Start Selling | Old Book Store</title>
    <link rel="stylesheet" href="styles/main.css">
    <link rel="stylesheet" href="styles/components.css">
    <style>
        .hero { display:flex; gap:24px; align-items:center; background:#f8f6f2; border:1px solid #eae3d2; border-radius:12px; padding:24px; }
        .hero img { width:45%; max-width:520px; border-radius:12px; }
        .hero h1 { margin:0 0 10px; }
        .btn-primary { background:#c7a17a; color:#fff; padding:10px 18px; border-radius:8px; text-decoration:none; display:inline-block; }
        .btn-primary:hover { background:#a67c52; }
        .plans { margin-top:24px; display:flex; gap:16px; }
        .plan { border:1px solid #eae3d2; border-radius:10px; padding:16px; flex:1; background:#fff; }
        .auth { margin-top:32px; padding:16px; border:1px solid #eae3d2; border-radius:10px; background:#fff; }
        input[type=email], input[type=password] { padding:8px; border:1px solid #ddd; border-radius:6px; width:260px; }
    </style>
    <script>
        function goSignup(){ window.location.href = 'signup.php'; }
    </script>
        </head>
    <body>
        <?php $activePage = 'start-selling'; include __DIR__ . '/inc/site_header.php'; ?>

    <main>
        <section class="hero">
            <img src="https://images.unsplash.com/photo-1519681393784-d120267933ba?q=80&w=1200&auto=format&fit=crop" alt="Sell your books">
            <div>
                <h1>Turn your old books into cash!</h1>
                <p>Join thousands of independent sellers. List your used books in minutes and reach readers everywhere.</p>
            </div>
        </section>

        <section class="plans">
            <div class="plan">
                <h3>Basic Plan</h3>
                <p><strong>Free</strong> to list. Platform fee on sales only.</p>
                <ul>
                    <li>Unlimited listings</li>
                    <li>Secure payments</li>
                    <li>Seller dashboard</li>
                </ul>
                <a class="btn-primary" href="signin.php">Start Selling with Basic</a>
            </div>
        </section>

        <?php if (!empty($faqs)): ?>
        <section style="margin-top:24px;">
            <h3>Seller FAQs</h3>
            <div id="faq-list" style="border:1px solid #eae3d2;border-radius:12px;background:#fff;overflow:hidden;">
                <?php foreach ($faqs as $i => $f): ?>
                    <div class="faq-item" style="border-bottom:1px solid #eae3d2;">
                        <button class="faq-q" style="width:100%;text-align:left;padding:12px 16px;background:#faf8f5;border:0;display:flex;justify-content:space-between;align-items:center;cursor:pointer;">
                            <span style="color:#6a4e42;font-weight:600;"><?= htmlspecialchars($f['question'], ENT_QUOTES, 'UTF-8') ?></span>
                            <span style="color:#a67c52">+</span>
                        </button>
                        <div class="faq-a" style="display:none;padding:12px 16px;color:#4a3c36;"><?= nl2br(htmlspecialchars($f['answer'], ENT_QUOTES, 'UTF-8')) ?></div>
                    </div>
                <?php endforeach; ?>
            </div>
        </section>
        <script>
        (function(){
            var items = document.querySelectorAll('#faq-list .faq-item');
            items.forEach(function(item){
                var q = item.querySelector('.faq-q');
                var a = item.querySelector('.faq-a');
                q.addEventListener('click', function(){
                    var open = a.style.display === 'block';
                    a.style.display = open ? 'none' : 'block';
                    q.querySelector('span:last-child').textContent = open ? '+' : '−';
                });
            });
        })();
        </script>
        <?php endif; ?>
    </main>
    <?php include __DIR__ . '/inc/site_footer.php'; ?>
</body>
</html>
