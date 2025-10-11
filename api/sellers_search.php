<?php
header('Content-Type: application/json');
require_once __DIR__ . '/../inc/db.php';

$seller_name = trim($_GET['seller_name'] ?? '');
$location    = trim($_GET['location'] ?? '');
$zip_code    = trim($_GET['zip_code'] ?? '');

$where = ["status = 'active'"];
$params = [];
$types = '';

if ($seller_name !== '') {
    // If input ends with %, treat as prefix; else use contains
    if (substr($seller_name, -1) === '%') {
        $where[] = 'username LIKE ?';
        $params[] = $seller_name;
    } else {
        $where[] = 'username LIKE ?';
        $params[] = '%' . $seller_name . '%';
    }
    $types .= 's';
}
if ($location !== '') {
    $where[] = 'location LIKE ?';
    $params[] = '%' . $location . '%';
    $types .= 's';
}
if ($zip_code !== '') {
    $where[] = 'zip_code LIKE ?';
    $params[] = $zip_code . '%';
    $types .= 's';
}

$sql = 'SELECT seller_id, username, email, full_name, phone, location, zip_code, profile_image, description FROM sellers';
if ($where) { $sql .= ' WHERE ' . implode(' AND ', $where); }
$sql .= ' ORDER BY username ASC LIMIT 100';

$results = [];
if ($stmt = mysqli_prepare($mysqli, $sql)) {
    if ($params) {
        $ref = [];
        foreach ($params as $k => $v) { $ref[$k] = &$params[$k]; }
        array_unshift($ref, $types);
        array_unshift($ref, $stmt);
        call_user_func_array('mysqli_stmt_bind_param', $ref);
    }
    mysqli_stmt_execute($stmt);
    $res = mysqli_stmt_get_result($stmt);
    while ($row = mysqli_fetch_assoc($res)) { $results[] = $row; }
    mysqli_stmt_close($stmt);
}

echo json_encode([ 'total' => count($results), 'results' => $results ]);
?>
