<?php
session_start();
require_once __DIR__ . '/inc/db.php';
require_once __DIR__ . '/inc/config.php';

// Only one admin: the user with email = $ADMIN_EMAIL
if (empty($_SESSION['user_id'])) {
    header('Location: signin.php?role=user&redirect=admin_dashboard.php');
    exit;
}

$isAdmin = false;
if ($stmt = mysqli_prepare($mysqli, 'SELECT email FROM users WHERE user_id = ? LIMIT 1')) {
    mysqli_stmt_bind_param($stmt, 'i', $_SESSION['user_id']);
    mysqli_stmt_execute($stmt);
    $res = mysqli_stmt_get_result($stmt);
    if ($row = mysqli_fetch_assoc($res)) {
        $isAdmin = (strcasecmp($row['email'], $ADMIN_EMAIL) === 0);
    }
    mysqli_stmt_close($stmt);
}

if (!$isAdmin) {
    http_response_code(403);
    echo 'Access denied: Admin only.';
    exit;
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Admin Dashboard</title>
    <link rel="stylesheet" href="styles/main.css">
    <link rel="stylesheet" href="styles/components.css">
</head>
<body>
    <?php $activePage = ''; include __DIR__ . '/inc/site_header.php'; ?>
    <main style="max-width:1000px;margin:32px auto;">
        <h2>Admin Dashboard</h2>
        <p>Welcome, Admin. From here, you can moderate sellers and manage listings. (Placeholder)</p>
        <ul>
            <li>Approve/suspend sellers</li>
            <li>Remove inappropriate listings</li>
            <li>View platform stats</li>
            <li><a href="admin_faqs.php">Manage Seller FAQs</a></li>
        </ul>
        <p><a href="signout.php">Sign out</a></p>
    </main>
    <?php include __DIR__ . '/inc/site_footer.php'; ?>
</body>
</html>
