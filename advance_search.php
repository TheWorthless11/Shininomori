<?php
session_start();
$db_user = "root";
$db_pass = "";
$db_name = "oldbookstore";
$db_host = "localhost";

$conn = mysqli_connect($db_host, $db_user, $db_pass, $db_name);
if (!$conn) {
    die("Database connection failed: " . mysqli_connect_error());
}

// Build SQL query based on form input
$where = [];
$params = [];

if (!empty($_GET['author'])) {
    $where[] = "LOWER(a.name) LIKE ?";
    $params[] = '%' . strtolower($_GET['author']) . '%';
}
if (!empty($_GET['title'])) {
    $where[] = "LOWER(b.title) LIKE ?";
    $params[] = '%' . strtolower($_GET['title']) . '%';
}
if (!empty($_GET['isbn'])) {
    $where[] = "b.isbn = ?";
    $params[] = $_GET['isbn'];
}
if (!empty($_GET['keywords'])) {
    $kw = '%' . strtolower($_GET['keywords']) . '%';
    $where[] = "(LOWER(b.title) LIKE ? OR LOWER(a.name) LIKE ? OR b.isbn LIKE ?)";
    $params[] = $kw;
    $params[] = $kw;
    $params[] = $kw;
}
if (!empty($_GET['publisher'])) {
    $where[] = "LOWER(b.publisher) LIKE ?";
    $params[] = '%' . strtolower($_GET['publisher']) . '%';
}
if (!empty($_GET['min_price'])) {
    $where[] = "b.price >= ?";
    $params[] = $_GET['min_price'];
}
if (!empty($_GET['max_price'])) {
    $where[] = "b.price <= ?";
    $params[] = $_GET['max_price'];
}
if (!empty($_GET['product_type'])) {
    $where[] = "b.product_type = ?";
    $params[] = $_GET['product_type'];
}
if (!empty($_GET['condition'])) {
    $where[] = "b.condition = ?";
    $params[] = $_GET['condition'];
}
if (!empty($_GET['binding'])) {
    $where[] = "b.binding = ?";
    $params[] = $_GET['binding'];
}
if (!empty($_GET['language'])) {
    $where[] = "LOWER(b.language) = ?";
    $params[] = strtolower($_GET['language']);
}
if (!empty($_GET['seller_name'])) {
    $where[] = "LOWER(s.name) LIKE ?";
    $params[] = '%' . strtolower($_GET['seller_name']) . '%';
}

// Sorting
$sort = "b.created_at DESC";
if (!empty($_GET['sort_by'])) {
    switch ($_GET['sort_by']) {
        case "price_asc": $sort = "b.price ASC"; break;
        case "price_desc": $sort = "b.price DESC"; break;
        case "author_az": $sort = "a.name ASC"; break;
        case "author_za": $sort = "a.name DESC"; break;
        case "newest": default: $sort = "b.created_at DESC"; break;
    }
}

// SQL Query
$sql = "
SELECT b.id, b.title, b.price, b.condition, b.binding, b.language, b.product_type, b.isbn, b.publisher, b.created_at,
       s.name AS seller_name, s.country, a.name AS author_name
FROM books b
JOIN sellers s ON b.seller_id = s.id
JOIN book_authors ba ON b.id = ba.book_id
JOIN authors a ON ba.author_id = a.id
";

if ($where) {
    $sql .= " WHERE " . implode(" AND ", $where);
}
$sql .= " ORDER BY $sort";

// Prepare and execute
$results = [];
if ($_GET) {
    $stmt = mysqli_prepare($conn, $sql);
    if ($stmt) {
        if ($params) {
            $types = str_repeat('s', count($params));
            mysqli_stmt_bind_param($stmt, $types, ...$params);
        }
        mysqli_stmt_execute($stmt);
        $res = mysqli_stmt_get_result($stmt);
        while ($row = mysqli_fetch_assoc($res)) {
            $results[] = $row;
        }
        mysqli_stmt_close($stmt);
    }
}
mysqli_close($conn);
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Advance Search | Old Book Store</title>
    <link rel="stylesheet" href="styles/main.css">
    <link rel="stylesheet" href="styles/components.css">
    </head>
<body>
    <?php $activePage = 'search'; include __DIR__ . '/inc/site_header.php'; ?>

    <main>
        <h2>Advance Search</h2>
        <p style="margin-bottom:18px;color:#6a4e42;">
            Enter at least one of Author, Title, ISBN, Keyword, or Publisher to search.
        </p>
        <form id="advance-search-form" method="GET" style="margin-bottom:32px;">
            <div style="display:flex;flex-wrap:wrap;gap:18px;">
                <input type="text" name="author" placeholder="Author" value="<?= htmlspecialchars($_GET['author'] ?? '') ?>" style="flex:1;">
                <input type="text" name="title" placeholder="Title" value="<?= htmlspecialchars($_GET['title'] ?? '') ?>" style="flex:1;">
                <input type="text" name="isbn" placeholder="ISBN" value="<?= htmlspecialchars($_GET['isbn'] ?? '') ?>" style="flex:1;">
                <input type="text" name="keywords" placeholder="Keywords" value="<?= htmlspecialchars($_GET['keywords'] ?? '') ?>" style="flex:1;">
                <input type="text" name="publisher" placeholder="Publisher" value="<?= htmlspecialchars($_GET['publisher'] ?? '') ?>" style="flex:1;">
            </div>
            <div style="display:flex;flex-wrap:wrap;gap:18px;margin-top:18px;">
                <input type="number" name="min_price" placeholder="Min Price" value="<?= htmlspecialchars($_GET['min_price'] ?? '') ?>" style="width:120px;">
                <input type="number" name="max_price" placeholder="Max Price" value="<?= htmlspecialchars($_GET['max_price'] ?? '') ?>" style="width:120px;">
                <select name="product_type" style="width:160px;">
                    <option value="">Product Type</option>
                    <option value="Book" <?= ($_GET['product_type'] ?? '')=='Book'?'selected':'' ?>>Book</option>
                    <option value="Comic" <?= ($_GET['product_type'] ?? '')=='Comic'?'selected':'' ?>>Comic</option>
                    <option value="Magazine" <?= ($_GET['product_type'] ?? '')=='Magazine'?'selected':'' ?>>Magazine</option>
                    <option value="Periodical" <?= ($_GET['product_type'] ?? '')=='Periodical'?'selected':'' ?>>Periodical</option>
                </select>
                <select name="condition" style="width:140px;">
                    <option value="">Condition</option>
                    <option value="New" <?= ($_GET['condition'] ?? '')=='New'?'selected':'' ?>>New</option>
                    <option value="Very Good" <?= ($_GET['condition'] ?? '')=='Very Good'?'selected':'' ?>>Very Good</option>
                    <option value="Good" <?= ($_GET['condition'] ?? '')=='Good'?'selected':'' ?>>Good</option>
                    <option value="Fair" <?= ($_GET['condition'] ?? '')=='Fair'?'selected':'' ?>>Fair</option>
                </select>
                <select name="binding" style="width:140px;">
                    <option value="">Binding</option>
                    <option value="Hardcover" <?= ($_GET['binding'] ?? '')=='Hardcover'?'selected':'' ?>>Hardcover</option>
                    <option value="Paperback" <?= ($_GET['binding'] ?? '')=='Paperback'?'selected':'' ?>>Paperback</option>
                </select>
                <input type="text" name="language" placeholder="Language" value="<?= htmlspecialchars($_GET['language'] ?? '') ?>" style="width:120px;">
                <input type="text" name="seller_name" placeholder="Seller Name" value="<?= htmlspecialchars($_GET['seller_name'] ?? '') ?>" style="width:160px;">
            </div>
            <div style="margin-top:18px;display:flex;align-items:center;gap:18px;">
                <label for="sort_by">Sort by:</label>
                <select name="sort_by" id="sort_by" style="width:180px;">
                    <option value="newest" <?= ($_GET['sort_by'] ?? '')=='newest'?'selected':'' ?>>Newest</option>
                    <option value="price_asc" <?= ($_GET['sort_by'] ?? '')=='price_asc'?'selected':'' ?>>Price ↑</option>
                    <option value="price_desc" <?= ($_GET['sort_by'] ?? '')=='price_desc'?'selected':'' ?>>Price ↓</option>
                    <option value="author_az" <?= ($_GET['sort_by'] ?? '')=='author_az'?'selected':'' ?>>Author (A–Z)</option>
                    <option value="author_za" <?= ($_GET['sort_by'] ?? '')=='author_za'?'selected':'' ?>>Author (Z–A)</option>
                </select>
                <button type="submit" class="explore-btn">Search</button>
                <button type="reset" class="explore-btn" style="background:#eae3d2;color:#6a4e42;">Reset</button>
            </div>
        </form>
        <section id="search-results">
            <?php if ($_GET): ?>
                <?php if ($results): ?>
                    <?php foreach ($results as $book): ?>
                        <div class="book-card">
                            <h3><?= htmlspecialchars($book['title']) ?></h3>
                            <p><strong>Author:</strong> <?= htmlspecialchars($book['author_name']) ?></p>
                            <p><strong>Price:</strong> ₹<?= htmlspecialchars($book['price']) ?></p>
                            <p><strong>Condition:</strong> <?= htmlspecialchars($book['condition']) ?> | <strong>Binding:</strong> <?= htmlspecialchars($book['binding']) ?></p>
                            <p><strong>Seller:</strong> <?= htmlspecialchars($book['seller_name']) ?> (<?= htmlspecialchars($book['country']) ?>)</p>
                            <a href="book-details.php?id=<?= htmlspecialchars($book['id']) ?>" class="view-btn">View</a>
                        </div>
                    <?php endforeach; ?>
                <?php else: ?>
                    <p>No books found matching your criteria.</p>
                <?php endif; ?>
            <?php endif; ?>
        </section>
    </main>
    <?php include __DIR__ . '/inc/site_footer.php'; ?>
    <script src="src/app.js"></script>
<!-- Code injected by live-server -->
<script>
	// <![CDATA[  <-- For SVG support
	if ('WebSocket' in window) {
		(function () {
			function refreshCSS() {
				var sheets = [].slice.call(document.getElementsByTagName("link"));
				var head = document.getElementsByTagName("head")[0];
				for (var i = 0; i < sheets.length; ++i) {
					var elem = sheets[i];
					var parent = elem.parentElement || head;
					parent.removeChild(elem);
					var rel = elem.rel;
					if (elem.href && typeof rel != "string" || rel.length == 0 || rel.toLowerCase() == "stylesheet") {
						var url = elem.href.replace(/(&|\?)_cacheOverride=\d+/, '');
						elem.href = url + (url.indexOf('?') >= 0 ? '&' : '?') + '_cacheOverride=' + (new Date().valueOf());
					}
					parent.appendChild(elem);
				}
			}
			var protocol = window.location.protocol === 'http:' ? 'ws://' : 'wss://';
			var address = protocol + window.location.host + window.location.pathname + '/ws';
			var socket = new WebSocket(address);
			socket.onmessage = function (msg) {
				if (msg.data == 'reload') window.location.reload();
				else if (msg.data == 'refreshcss') refreshCSS();
			};
			if (sessionStorage && !sessionStorage.getItem('IsThisFirstTime_Log_From_LiveServer')) {
				console.log('Live reload enabled.');
				sessionStorage.setItem('IsThisFirstTime_Log_From_LiveServer', true);
			}
		})();
	}
	else {
		console.error('Upgrade your browser. This Browser is NOT supported WebSocket for Live-Reloading.');
	}
	// ]]>
</script>
<!-- Code injected by live-server -->
<script>
	// <![CDATA[  <-- For SVG support
	if ('WebSocket' in window) {
		(function () {
			function refreshCSS() {
				var sheets = [].slice.call(document.getElementsByTagName("link"));
				var head = document.getElementsByTagName("head")[0];
				for (var i = 0; i < sheets.length; ++i) {
					var elem = sheets[i];
					var parent = elem.parentElement || head;
					parent.removeChild(elem);
					var rel = elem.rel;
					if (elem.href && typeof rel != "string" || rel.length == 0 || rel.toLowerCase() == "stylesheet") {
						var url = elem.href.replace(/(&|\?)_cacheOverride=\d+/, '');
						elem.href = url + (url.indexOf('?') >= 0 ? '&' : '?') + '_cacheOverride=' + (new Date().valueOf());
					}
					parent.appendChild(elem);
				}
			}
			var protocol = window.location.protocol === 'http:' ? 'ws://' : 'wss://';
			var address = protocol + window.location.host + window.location.pathname + '/ws';
			var socket = new WebSocket(address);
			socket.onmessage = function (msg) {
				if (msg.data == 'reload') window.location.reload();
				else if (msg.data == 'refreshcss') refreshCSS();
			};
			if (sessionStorage && !sessionStorage.getItem('IsThisFirstTime_Log_From_LiveServer')) {
				console.log('Live reload enabled.');
				sessionStorage.setItem('IsThisFirstTime_Log_From_LiveServer', true);
			}
		})();
	}
	else {
		console.error('Upgrade your browser. This Browser is NOT supported WebSocket for Live-Reloading.');
	}
	// ]]>
</script>
</body>
</html>