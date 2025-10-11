<?php
// sellers.php - Find independent sellers near you (with live AJAX search)
session_start();
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Sellers | Old Book Store</title>
    <link rel="stylesheet" href="styles/main.css">
    <link rel="stylesheet" href="styles/components.css">
    <style>
        .seller-search { background:#f8f6f2; border:1px solid #eae3d2; border-radius:8px; padding:16px; margin-bottom:16px; }
        .seller-list { display:grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap:14px; }
        .seller-card { background:#fff; border:1px solid #eae3d2; border-radius:8px; padding:14px; display:flex; gap:12px; align-items:flex-start; }
        .seller-card img { width:64px; height:64px; object-fit:cover; border-radius:50%; border:1px solid #ddd; }
        .alpha { display:flex; flex-wrap:wrap; gap:6px; margin:12px 0; }
        .alpha a { padding:4px 8px; border:1px solid #e0d7c8; border-radius:6px; text-decoration:none; color:#6a4e42; }
        .alpha a.active, .alpha a:hover { background:#efe8dd; }
        .btn-red { background:#cc2936; color:#fff; border:none; padding:8px 14px; border-radius:6px; cursor:pointer; }
        .muted { color:#6a4e42; font-size:13px; }
    </style>
    <script>
        async function fetchSellers(params) {
            const url = new URL('api/sellers_search.php', window.location.origin + window.location.pathname.replace(/[^/]*$/, ''));
            for (const [k, v] of Object.entries(params)) { if (v) url.searchParams.set(k, v); }
            const res = await fetch(url.toString());
            const data = await res.json();
            const list = document.getElementById('seller-results');
            list.innerHTML = '';
            data.results.forEach(s => {
                const card = document.createElement('div');
                card.className = 'seller-card';
                const img = document.createElement('img');
                img.src = s.profile_image || 'https://via.placeholder.com/64?text=S';
                img.alt = s.username;
                const info = document.createElement('div');
                info.innerHTML = `<strong>${escapeHtml(s.username)}</strong><div class="muted">${escapeHtml(s.full_name||'')}</div>`+
                                 `<div class="muted">${escapeHtml(s.location||'')} ${s.zip_code?('('+escapeHtml(s.zip_code)+')'):''}</div>`+
                                 `<div class="muted">${escapeHtml(s.description||'')}</div>`;
                card.appendChild(img);
                card.appendChild(info);
                list.appendChild(card);
            });
            document.getElementById('results-count').textContent = data.total;
        }
        function escapeHtml(s){return (s||'').replace(/[&<>"]+/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]));}
        function init() {
            const form = document.getElementById('seller-form');
            form.addEventListener('submit', e => {
                e.preventDefault();
                const params = Object.fromEntries(new FormData(form).entries());
                fetchSellers(params);
            });
            document.querySelectorAll('.alpha a').forEach(a => {
                a.addEventListener('click', e => {
                    e.preventDefault();
                    document.getElementById('seller_name').value = a.dataset.letter;
                    fetchSellers({ seller_name: a.dataset.letter });
                });
            });
            // Initial load
            fetchSellers({});
        }
        window.addEventListener('DOMContentLoaded', init);
    </script>
</head>
<body>
    <?php $activePage = 'sellers'; include __DIR__ . '/inc/site_header.php'; ?>

    <main>
        <h2>Find independent sellers near you</h2>
        <div class="seller-search">
            <form id="seller-form">
                <input type="text" id="seller_name" name="seller_name" placeholder="Seller name (username)">
                <input type="text" name="location" placeholder="Location (city/area)">
                <input type="text" name="zip_code" placeholder="ZIP / Postal code">
                <button class="btn-red" type="submit">Search</button>
            </form>
            <div class="alpha">
                <?php foreach (range('A','Z') as $L): ?>
                    <a href="#" data-letter="<?= $L ?>%"><?= $L ?></a>
                <?php endforeach; ?>
            </div>
            <div class="muted"><span id="results-count">0</span> sellers found</div>
        </div>

        <section class="seller-list" id="seller-results"></section>
    </main>
    <?php include __DIR__ . '/inc/site_footer.php'; ?>
</body>
</html>
