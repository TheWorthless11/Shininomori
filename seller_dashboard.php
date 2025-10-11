<?php
session_start();
if (empty($_SESSION['seller_id'])) {
    header('Location: signin.php?redirect=seller_dashboard.php');
    exit;
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Seller Dashboard</title>
    <link rel="stylesheet" href="styles/main.css">
    <link rel="stylesheet" href="styles/components.css">
</head>
<body>
    <?php $activePage = ''; include __DIR__ . '/inc/site_header.php'; ?>
    <main style="max-width:900px;margin:32px auto;">
        <h2>Welcome to your dashboard</h2>
        <?php
        // Optional: Show admin link if this seller is also the configured admin user via same email in users table
        require_once __DIR__ . '/inc/db.php';
        require_once __DIR__ . '/inc/config.php';
        if ($stmt = mysqli_prepare($mysqli, 'SELECT u.email FROM users u JOIN sellers s ON s.email = u.email WHERE s.seller_id = ? LIMIT 1')) {
            mysqli_stmt_bind_param($stmt, 'i', $_SESSION['seller_id']);
            mysqli_stmt_execute($stmt);
            $res = mysqli_stmt_get_result($stmt);
            if ($row = mysqli_fetch_assoc($res)) {
                if (strcasecmp($row['email'], $ADMIN_EMAIL) === 0) {
                    echo '<p><a href="admin_dashboard.php">Go to Admin Dashboard</a></p>';
                }
            }
            mysqli_stmt_close($stmt);
        }
        ?>
        <p>Here you can manage your listings, edit profile, and view orders. (Placeholder)</p>
        <ul>
            <li><a href="#">Add new listing</a> (coming soon)</li>
            <li><a href="#">Manage listings</a> (coming soon)</li>
            <li><a href="#">Edit profile</a> (coming soon)</li>
        </ul>
        <p><a href="signout.php">Sign out</a></p>
    </main>
    <?php include __DIR__ . '/inc/site_footer.php'; ?>
</body>
</html>
