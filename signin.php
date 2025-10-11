<?php
session_start();
require_once __DIR__ . '/inc/db.php';
require_once __DIR__ . '/inc/config.php';

$role = $_POST['role'] ?? ($_GET['role'] ?? 'seller');
$redirect = $_POST['redirect'] ?? (
    $_GET['redirect'] ?? (
        $role==='seller' ? 'seller_dashboard.php' : ($role==='admin' ? 'admin_dashboard.php' : 'user_dashboard.php')
    )
);
$error = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = trim($_POST['email'] ?? '');
    $password = $_POST['password'] ?? '';
    if ($email && $password) {
        if ($role === 'admin') {
            if ($stmt = mysqli_prepare($mysqli, "SELECT user_id AS id, password, email, status FROM users WHERE email = ? LIMIT 1")) {
                mysqli_stmt_bind_param($stmt, 's', $email);
                mysqli_stmt_execute($stmt);
                $res = mysqli_stmt_get_result($stmt);
                if ($row = mysqli_fetch_assoc($res)) {
                    if (strcasecmp($row['email'], $ADMIN_EMAIL) !== 0) {
                        $error = 'Invalid admin credentials.';
                    } elseif ($row['status'] !== 'active') {
                        $error = 'Account is not active.';
                    } elseif (password_verify($password, $row['password'])) {
                        $_SESSION['user_id'] = $row['id'];
                        $_SESSION['is_admin'] = true;
                        header('Location: ' . $redirect);
                        exit;
                    } else { $error = 'Invalid admin credentials.'; }
                } else { $error = 'Invalid admin credentials.'; }
                mysqli_stmt_close($stmt);
            }
        } elseif ($role === 'seller') {
            $sql = "SELECT seller_id AS id, password, status FROM sellers WHERE email = ? LIMIT 1";
            if ($stmt = mysqli_prepare($mysqli, $sql)) {
                mysqli_stmt_bind_param($stmt, 's', $email);
                mysqli_stmt_execute($stmt);
                $res = mysqli_stmt_get_result($stmt);
                if ($row = mysqli_fetch_assoc($res)) {
                    if ($row['status'] !== 'active') {
                        $error = 'Account is not active.';
                    } elseif (password_verify($password, $row['password'])) {
                        $_SESSION['seller_id'] = $row['id'];
                        header('Location: ' . $redirect);
                        exit;
                    } else { $error = 'Invalid credentials.'; }
                } else { $error = 'Invalid credentials.'; }
                mysqli_stmt_close($stmt);
            }
        } else { // user
            $sql = "SELECT user_id AS id, password, status FROM users WHERE email = ? LIMIT 1";
            if ($stmt = mysqli_prepare($mysqli, $sql)) {
                mysqli_stmt_bind_param($stmt, 's', $email);
                mysqli_stmt_execute($stmt);
                $res = mysqli_stmt_get_result($stmt);
                if ($row = mysqli_fetch_assoc($res)) {
                    if ($row['status'] !== 'active') {
                        $error = 'Account is not active.';
                    } elseif (password_verify($password, $row['password'])) {
                        $_SESSION['user_id'] = $row['id'];
                        header('Location: ' . $redirect);
                        exit;
                    } else { $error = 'Invalid credentials.'; }
                } else { $error = 'Invalid credentials.'; }
                mysqli_stmt_close($stmt);
            }
        }
    } else { $error = 'Email and Password are required.'; }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Sign In | Old Book Store</title>
    <link rel="stylesheet" href="styles/main.css">
    <link rel="stylesheet" href="styles/components.css">
    <style> body { background: #f4efe9; } </style>
</head>
<body>
    <main class="auth-page">
        <div class="auth-card">
            <div class="auth-header">
                <h2 class="auth-title">Welcome back</h2>
                <p class="auth-subtitle">Sign in to continue</p>
            </div>
            <?php if ($error): ?><div class="auth-alert"><?php echo htmlspecialchars($error); ?></div><?php endif; ?>
            <form method="POST" autocomplete="off" class="auth-form">
                <input type="hidden" name="redirect" value="<?= htmlspecialchars($redirect) ?>">
                <input type="text" name="dummy-username" style="display:none" tabindex="-1" aria-hidden="true" autocomplete="off">
                <input type="password" name="dummy-password" style="display:none" tabindex="-1" aria-hidden="true" autocomplete="new-password">

                <label>Sign in as</label>
                <select name="role" class="auth-input">
                    <option value="seller" <?= ($role==='seller')?'selected':'' ?>>Seller</option>
                    <option value="user" <?= ($role==='user')?'selected':'' ?>>User</option>
                    <option value="admin" <?= ($role==='admin')?'selected':'' ?>>Admin</option>
                </select>

                <input class="auth-input" type="email" name="email" placeholder="Email" required autocomplete="off" autocapitalize="none" spellcheck="false" inputmode="email" readonly onfocus="this.removeAttribute('readonly');">
                <input class="auth-input" type="password" name="password" placeholder="Password" required autocomplete="new-password" readonly onfocus="this.removeAttribute('readonly');">
                <div class="auth-actions" style="display:flex; gap:8px;">
                    <button type="submit" class="btn btn-primary" style="flex:1">Sign In</button>
                    <button type="reset" class="btn btn-secondary" style="width:140px">Reset</button>
                </div>
            </form>
            <p class="auth-alt">Don’t have an account? <a href="signup.php<?= $role==='admin' ? '' : ('?role=' . urlencode($role)) ?>">Create one</a> <?= $role==='admin' ? '(Use your normal user account; only the configured admin email can access Admin.)' : '' ?></p>
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
