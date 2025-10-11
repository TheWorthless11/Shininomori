<?php
session_start();
if (empty($_SESSION['user_id'])) {
    header('Location: signin.php?role=user&redirect=user_dashboard.php');
    exit;
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>User Dashboard</title>
    <link rel="stylesheet" href="styles/main.css">
    <link rel="stylesheet" href="styles/components.css">
</head>
<body>
    <?php $activePage = ''; include __DIR__ . '/inc/site_header.php'; ?>
    <main style="max-width:900px;margin:32px auto;">
        <h2>User Dashboard</h2>
        <?php
        require_once __DIR__ . '/inc/db.php';
        require_once __DIR__ . '/inc/config.php';
        // Show Admin link if this user is the configured admin email
        if ($stmt = mysqli_prepare($mysqli, 'SELECT email FROM users WHERE user_id = ?')) {
            mysqli_stmt_bind_param($stmt, 'i', $_SESSION['user_id']);
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
        <p>This is your user dashboard. From here, you can manage your profile, view orders, and save favorites. (Placeholder)</p>
        <p><a href="signout.php">Sign out</a></p>
    </main>
    <?php include __DIR__ . '/inc/site_footer.php'; ?>
</body>
</html>
