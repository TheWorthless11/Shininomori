<?php
// browse.php — Browse listings with categories, sorting, and pagination (MySQLi)
session_start();

// DB connection
$db_user = "root";
$db_pass = "";
$db_name = "oldbookstore";
$db_host = "localhost";
$conn = mysqli_connect($db_host, $db_user, $db_pass, $db_name);
if (!$conn) {
    die("Database connection failed: " . mysqli_connect_error());
}

// Helpers
function h($v) { return htmlspecialchars((string)$v, ENT_QUOTES, 'UTF-8'); }
function build_query(array $overrides = []) {
    $q = array_merge($_GET, $overrides);
    return http_build_query(array_filter($q, function($v) { return $v !== '' && $v !== null; }));
}
// Bind helper for dynamic params (by reference)
function bind_params_ref($stmt, $types, $params) {
    $refs = [];
    foreach ($params as $k => $v) { $refs[$k] = &$params[$k]; }
    array_unshift($refs, $types);
    array_unshift($refs, $stmt);
    return call_user_func_array('mysqli_stmt_bind_param', $refs);
}
// Inputs
$category = isset($_GET['category']) ? trim($_GET['category']) : '';
$min_price = isset($_GET['min_price']) ? trim($_GET['min_price']) : '';
$max_price = isset($_GET['max_price']) ? trim($_GET['max_price']) : '';
$keywords  = isset($_GET['keywords']) ? trim($_GET['keywords']) : '';
$sort_by   = isset($_GET['sort_by']) ? $_GET['sort_by'] : 'newest';
$page      = max(1, (int)($_GET['page'] ?? 1));
$per_page  = max(1, min(24, (int)($_GET['per_page'] ?? 12)));
$offset    = ($page - 1) * $per_page;

// Build filters
$where = [];
$params = [];
$types = '';

// Optional active flag; will be gracefully removed on fallback if column doesn't exist
$activeFilter = 'b.is_active = 1';
$where[] = $activeFilter;

if ($category !== '') {
    $where[] = 'b.product_type = ?';
    $params[] = $category;
    $types   .= 's';
}
if ($min_price !== '') {
    $where[] = 'b.price >= ?';
    $params[] = (float)$min_price;
    $types   .= 'd';
}
if ($max_price !== '') {
    $where[] = 'b.price <= ?';
    $params[] = (float)$max_price;
    $types   .= 'd';
}
if ($keywords !== '') {
    $kw = '%' . strtolower($keywords) . '%';
    $where[] = '(LOWER(b.title) LIKE ? OR LOWER(a.name) LIKE ? OR b.isbn LIKE ?)';
    $params[] = $kw; $params[] = $kw; $params[] = $kw;
    $types   .= 'sss';
}

// Sorting
switch ($sort_by) {
    case 'price_asc':  $order = 'b.price ASC'; break;
    case 'price_desc': $order = 'b.price DESC'; break;
    case 'author_az':  $order = 'authors ASC'; break;
    case 'author_za':  $order = 'authors DESC'; break;
    case 'newest':
    default:           $order = 'b.created_at DESC'; break;
}

// Base FROM/JOIN
$fromJoin = "FROM books b
JOIN sellers s ON b.seller_id = s.id
JOIN book_authors ba ON b.id = ba.book_id
JOIN authors a ON ba.author_id = a.id";

$whereSql = $where ? (' WHERE ' . implode(' AND ', $where)) : '';

// Count distinct books for pagination
$countSql = "SELECT COUNT(DISTINCT b.id) AS total " . $fromJoin . $whereSql;

// Listing query with author aggregation
$listSql = "SELECT 
    b.id,
    b.title,
    b.price,
    b.`condition`,
    b.binding,
    s.name AS seller_name,
    s.country,
    GROUP_CONCAT(DISTINCT a.name ORDER BY a.name SEPARATOR ', ') AS authors
" . $fromJoin . $whereSql . "
GROUP BY b.id, b.title, b.price, b.`condition`, b.binding, s.name, s.country
ORDER BY $order
LIMIT ? OFFSET ?";

// Execute with graceful fallback if is_active column doesn't exist
$total = 0; $results = [];
for ($attempt = 0; $attempt < 2; $attempt++) {
    // Count
    if ($stmt = mysqli_prepare($conn, $countSql)) {
        if ($params) { bind_params_ref($stmt, $types, $params); }
        if (!mysqli_stmt_execute($stmt)) {
            $err = mysqli_stmt_error($stmt);
            mysqli_stmt_close($stmt);
            if (strpos($err, "Unknown column 'is_active'") !== false && $attempt == 0) {
                // Remove active filter and retry
                $where = array_values(array_filter($where, fn($w) => $w !== $activeFilter));
                $whereSql = $where ? (' WHERE ' . implode(' AND ', $where)) : '';
                $countSql = "SELECT COUNT(DISTINCT b.id) AS total " . $fromJoin . $whereSql;
                $listSql = "SELECT 
                    b.id, b.title, b.price, b.`condition`, b.binding,
                    s.name AS seller_name, s.country,
                    GROUP_CONCAT(DISTINCT a.name ORDER BY a.name SEPARATOR ', ') AS authors
                " . $fromJoin . $whereSql . "
                GROUP BY b.id, b.title, b.price, b.`condition`, b.binding, s.name, s.country
                ORDER BY $order
                LIMIT ? OFFSET ?";
                continue; // retry loop
            } else {
                break; // give up
            }
        }
        $res = mysqli_stmt_get_result($stmt);
        if ($row = mysqli_fetch_assoc($res)) { $total = (int)$row['total']; }
        mysqli_stmt_close($stmt);
    }

    // List
    $listParams = $params; $listTypes = $types . 'ii';
    $listParams[] = $per_page; $listParams[] = $offset;
    if ($stmt = mysqli_prepare($conn, $listSql)) {
        bind_params_ref($stmt, $listTypes, $listParams);
        if (!mysqli_stmt_execute($stmt)) {
            $err = mysqli_stmt_error($stmt);
            mysqli_stmt_close($stmt);
            if (strpos($err, "Unknown column 'is_active'") !== false && $attempt == 0) {
                // Adjusted above already, retry
                continue;
            }
        } else {
            $res = mysqli_stmt_get_result($stmt);
            while ($row = mysqli_fetch_assoc($res)) { $results[] = $row; }
            mysqli_stmt_close($stmt);
        }
    }
    break; // success path
}

// Pagination numbers (guard against zero/invalid per_page)
$per_page = max(1, (int)$per_page);
$total_pages = max(1, (int)ceil($total / $per_page));
if ($page > $total_pages) { $page = $total_pages; }

mysqli_close($conn);
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Browse | Old Book Store</title>
    <link rel="stylesheet" href="styles/main.css">
    <link rel="stylesheet" href="styles/components.css">
    <style>
        .layout { display:flex; gap:24px; align-items:flex-start; }
        .sidebar { width:240px; background:#f8f6f2; border:1px solid #eae3d2; border-radius:8px; padding:16px; }
        .sidebar h3 { margin-top:0; color:#6a4e42; }
        .sidebar a { display:block; padding:8px 6px; color:#6a4e42; text-decoration:none; border-radius:6px; }
        .sidebar a.active, .sidebar a:hover { background:#efe8dd; }
        .content { flex:1; }
        .toolbar { display:flex; justify-content:space-between; align-items:center; margin-bottom:12px; }
        .grid { display:grid; grid-template-columns: repeat(auto-fill, minmax(260px, 1fr)); gap:16px; }
        .book-card { background:#fff; border:1px solid #eae3d2; border-radius:8px; padding:14px; box-shadow:0 1px 4px rgba(0,0,0,0.05); }
        .book-card h3 { margin:0 0 6px 0; font-size:18px; color:#333; }
        .muted { color:#6a4e42; font-size:13px; }
        .price { font-weight:700; color:#2c6e49; }
        .view-btn { display:inline-block; margin-top:8px; padding:6px 12px; background:#c7a17a; color:#fff; border-radius:4px; text-decoration:none; }
        .view-btn:hover { background:#a67c52; }
        .pagination { display:flex; gap:8px; justify-content:center; margin:20px 0; }
        .pagination a, .pagination span { padding:6px 10px; border:1px solid #e0d7c8; border-radius:6px; text-decoration:none; color:#6a4e42; }
        .pagination .current { background:#efe8dd; font-weight:700; }
        .filters small { color:#6a4e42; }
        form.inline { display:flex; gap:10px; align-items:center; }
        input[type=number] { width:100px; }
        .logo img { height:42px; display:block; }
    </style>
</head>
<body>
    <?php $activePage = 'browse'; include __DIR__ . '/inc/site_header.php'; ?>

    <main class="layout">
        <aside class="sidebar">
            <h3>Categories</h3>
            <?php
            $cats = ['Book' => 'Books', 'Comic' => 'Comics', 'Magazine' => 'Magazines', 'Periodical' => 'Periodicals'];
            foreach ($cats as $val => $label):
                $isActive = ($category === $val);
                $qs = build_query(['category' => $val, 'page' => 1]);
            ?>
                <a href="?<?= h($qs) ?>" class="<?= $isActive ? 'active' : '' ?>"><?= h($label) ?></a>
            <?php endforeach; ?>

            <h3 style="margin-top:18px;">Filters</h3>
            <form class="inline" method="GET" id="price-filter-form">
                <input type="hidden" name="category" value="<?= h($category) ?>">
                <input type="hidden" name="sort_by" value="<?= h($sort_by) ?>">
                <label>Min</label><input type="number" name="min_price" step="0.01" value="<?= h($min_price) ?>">
                <label>Max</label><input type="number" name="max_price" step="0.01" value="<?= h($max_price) ?>">
                <button type="submit" class="btn btn-primary">Apply</button>
                <button type="button" class="btn btn-secondary" id="reset-price-filters">Reset</button>
            </form>
            <small>Clear filters: <a href="browse.php">Reset</a></small>
        </aside>

        <section class="content">
            <div class="toolbar">
                <div class="filters">
                    <strong><?= h($total) ?></strong> results<?= $category ? ' in ' . h($cats[$category] ?? $category) : '' ?>
                </div>
                <form method="GET">
                    <input type="hidden" name="category" value="<?= h($category) ?>">
                    <input type="hidden" name="min_price" value="<?= h($min_price) ?>">
                    <input type="hidden" name="max_price" value="<?= h($max_price) ?>">
                    <input type="hidden" name="keywords" value="<?= h($keywords) ?>">
                    <label for="sort_by">Sort by:</label>
                    <select name="sort_by" id="sort_by" onchange="this.form.submit()">
                        <option value="newest" <?= $sort_by==='newest'?'selected':'' ?>>Newest</option>
                        <option value="price_asc" <?= $sort_by==='price_asc'?'selected':'' ?>>Price ↑</option>
                        <option value="price_desc" <?= $sort_by==='price_desc'?'selected':'' ?>>Price ↓</option>
                        <option value="author_az" <?= $sort_by==='author_az'?'selected':'' ?>>Author (A–Z)</option>
                        <option value="author_za" <?= $sort_by==='author_za'?'selected':'' ?>>Author (Z–A)</option>
                    </select>
                </form>
            </div>

            <?php if ($results): ?>
                <div class="grid">
                    <?php foreach ($results as $book): ?>
                        <div class="book-card">
                            <h3><?= h($book['title']) ?></h3>
                            <div class="muted">By <?= h($book['authors'] ?: 'Unknown') ?></div>
                            <div style="margin:6px 0;" class="muted">
                                <strong>Condition:</strong> <?= h($book['condition']) ?> |
                                <strong>Binding:</strong> <?= h($book['binding']) ?>
                            </div>
                            <div class="price">₹<?= h($book['price']) ?></div>
                            <div class="muted" style="margin-top:6px;">
                                <strong>Seller:</strong> <?= h($book['seller_name']) ?><?= $book['country'] ? ' (' . h($book['country']) . ')' : '' ?>
                            </div>
                            <a class="view-btn" href="book-details.php?id=<?= h($book['id']) ?>">View</a>
                        </div>
                    <?php endforeach; ?>
                </div>
            <?php else: ?>
                <p>No listings found.</p>
            <?php endif; ?>

            <div class="pagination">
                <?php if ($page > 1): ?>
                    <a href="?<?= h(build_query(['page' => $page - 1])) ?>">Previous</a>
                <?php else: ?>
                    <span class="disabled">Previous</span>
                <?php endif; ?>
                <span class="current">Page <?= h($page) ?> of <?= h($total_pages) ?></span>
                <?php if ($page < $total_pages): ?>
                    <a href="?<?= h(build_query(['page' => $page + 1])) ?>">Next</a>
                <?php else: ?>
                    <span class="disabled">Next</span>
                <?php endif; ?>
            </div>
        </section>
    </main>

    <?php include __DIR__ . '/inc/site_footer.php'; ?>
    <script src="src/app.js"></script>
    <script>
    (function(){
        var btn = document.getElementById('reset-price-filters');
        if (btn) {
            btn.addEventListener('click', function(){
                var form = document.getElementById('price-filter-form');
                if (!form) return;
                var min = form.querySelector('input[name="min_price"]');
                var max = form.querySelector('input[name="max_price"]');
                if (min) min.value = '';
                if (max) max.value = '';
                form.submit();
            });
        }
    })();
    </script>
</body>
</html>
