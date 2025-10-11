<?php
require_once __DIR__ . '/inc/db.php';
session_start();

$message = '';
$role = $_POST['role'] ?? ($_GET['role'] ?? 'user');
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username = trim($_POST['username'] ?? '');
    $email = trim($_POST['email'] ?? '');
    $password = $_POST['password'] ?? '';
    $full_name = trim($_POST['full_name'] ?? '');
    $location = trim($_POST['location'] ?? '');
    $zip_code = trim($_POST['zip_code'] ?? '');

    if ($username && $email && $password) {
        $hash = password_hash($password, PASSWORD_DEFAULT);
        if ($role === 'seller') {
            $sql = "INSERT INTO sellers (username, email, password, full_name, location, zip_code, status) VALUES (?,?,?,?,?,?, 'active')";
        } else {
            $sql = "INSERT INTO users (username, email, password, full_name, location, zip_code, status) VALUES (?,?,?,?,?,?, 'active')";
        }
        if ($stmt = mysqli_prepare($mysqli, $sql)) {
            mysqli_stmt_bind_param($stmt, 'ssssss', $username, $email, $hash, $full_name, $location, $zip_code);
            if (mysqli_stmt_execute($stmt)) {
                if ($role === 'seller') {
                    $_SESSION['seller_id'] = mysqli_insert_id($mysqli);
                    header('Location: seller_dashboard.php');
                } else {
                    $_SESSION['user_id'] = mysqli_insert_id($mysqli);
                    header('Location: user_dashboard.php');
                }
                exit;
            } else {
                $message = 'Signup failed: ' . htmlspecialchars(mysqli_error($mysqli));
            }
            mysqli_stmt_close($stmt);
        }
    } else { $message = 'Username, Email and Password are required.'; }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Sign Up | Old Book Store</title>
    <link rel="stylesheet" href="styles/main.css">
    <link rel="stylesheet" href="styles/components.css">
    <style> body { background: #f4efe9; } </style>
</head>
<body>
    <main class="auth-page">
        <div class="auth-card">
            <div class="auth-header">
                <h2 class="auth-title">Create your account</h2>
                <p class="auth-subtitle">Join ShiniNoMori</p>
            </div>
            <?php if ($message): ?><div class="auth-alert"><?php echo $message; ?></div><?php endif; ?>
            <form method="POST" autocomplete="off" class="auth-form grid-2">
                <input type="text" name="dummy-username" style="display:none" tabindex="-1" aria-hidden="true" autocomplete="off">
                <input type="password" name="dummy-password" style="display:none" tabindex="-1" aria-hidden="true" autocomplete="new-password">

                <label style="grid-column:1/-1;">Sign up as
                    <select name="role" class="auth-input">
                        <option value="user" <?= ($role==='user')?'selected':'' ?>>User</option>
                        <option value="seller" <?= ($role==='seller')?'selected':'' ?>>Seller</option>
                    </select>
                </label>

                <input class="auth-input" name="username" placeholder="Username" required>
                <input class="auth-input" name="email" type="email" placeholder="Email" required autocomplete="off" autocapitalize="none" spellcheck="false" inputmode="email" readonly onfocus="this.removeAttribute('readonly');">
                <input class="auth-input" name="password" type="password" placeholder="Password" required autocomplete="new-password" readonly onfocus="this.removeAttribute('readonly');">
                <input class="auth-input" name="full_name" placeholder="Full name (optional)">
                <input class="auth-input" name="location" placeholder="City / Area">
                <input class="auth-input" name="zip_code" placeholder="ZIP / Postal Code">
                <div style="grid-column:1/-1; display:flex; gap:8px;" class="auth-actions">
                    <button type="submit" class="btn btn-primary" style="flex:1">Create Account</button>
                    <button type="reset" class="btn btn-secondary" style="width:140px">Reset</button>
                </div>
            </form>
            <p class="auth-alt">Already have an account? <a href="signin.php">Sign in</a></p>
        </div>
    </main>
    <script>
    document.addEventListener('DOMContentLoaded', function(){
        var e = document.querySelector('input[name="email"]');
        var p = document.querySelector('input[name="password"]');
        if (e && e.value) e.value = '';
        if (p && p.value) p.value = '';
    });
    </script>
</body>
</html>
