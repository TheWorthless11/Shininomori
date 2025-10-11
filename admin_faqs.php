<?php
session_start();
require_once __DIR__ . '/inc/db.php';
require_once __DIR__ . '/inc/config.php';
require_once __DIR__ . '/inc/faq.php';

// Auth: only configured admin can access
if (empty($_SESSION['user_id'])) { header('Location: signin.php?role=user&redirect=admin_faqs.php'); exit; }
$isAdmin = false;
if ($stmt = mysqli_prepare($mysqli, 'SELECT email FROM users WHERE user_id = ? LIMIT 1')) {
    mysqli_stmt_bind_param($stmt, 'i', $_SESSION['user_id']);
    mysqli_stmt_execute($stmt);
    $res = mysqli_stmt_get_result($stmt);
    if ($row = mysqli_fetch_assoc($res)) { $isAdmin = (strcasecmp($row['email'], $ADMIN_EMAIL) === 0); }
    mysqli_stmt_close($stmt);
}
if (!$isAdmin) { http_response_code(403); echo 'Access denied'; exit; }

// Handle CRUD
$msg = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';
    if ($action === 'create') {
        $q = trim($_POST['question'] ?? '');
        $a = trim($_POST['answer'] ?? '');
        $active = isset($_POST['is_active']) ? 1 : 0;
        if ($q && $a) { $ok = faq_create($mysqli, $q, $a, $active); $msg = $ok ? 'FAQ created.' : 'Create failed.'; }
        else { $msg = 'Question and Answer are required.'; }
    } elseif ($action === 'update') {
        $id = (int)($_POST['id'] ?? 0);
        $q = trim($_POST['question'] ?? '');
        $a = trim($_POST['answer'] ?? '');
        $active = isset($_POST['is_active']) ? 1 : 0;
        if ($id && $q && $a) { $ok = faq_update($mysqli, $id, $q, $a, $active); $msg = $ok ? 'FAQ updated.' : 'Update failed.'; }
        else { $msg = 'All fields are required.'; }
    } elseif ($action === 'delete') {
        $id = (int)($_POST['id'] ?? 0);
        if ($id) { $ok = faq_delete($mysqli, $id); $msg = $ok ? 'FAQ deleted.' : 'Delete failed.'; }
    }
}

$faqs = faq_all($mysqli, false);
function h($v){ return htmlspecialchars((string)$v, ENT_QUOTES, 'UTF-8'); }
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Manage Seller FAQs</title>
    <link rel="stylesheet" href="styles/main.css">
    <link rel="stylesheet" href="styles/components.css">
    <style>
        .admin-wrap{max-width:1000px;margin:24px auto;background:#fff;border-radius:12px;border:1px solid #eae3d2;padding:20px;}
        .faq-row{border:1px solid #eae3d2;border-radius:8px;padding:12px;margin-bottom:10px;background:#faf8f5;}
        .faq-row h4{margin:0 0 8px 0;color:#6a4e42}
        .form-grid{display:grid;grid-template-columns:1fr;gap:8px;margin-bottom:16px}
        textarea, input[type=text]{padding:8px;border:1px solid #d6c6b1;border-radius:8px;width:100%}
        .actions{display:flex;gap:8px}
    </style>
</head>
<body>
    <?php $activePage = ''; include __DIR__ . '/inc/site_header.php'; ?>
    <main class="admin-wrap">
        <h2>Seller FAQs</h2>
        <?php if ($msg): ?><div class="auth-alert"><?= h($msg) ?></div><?php endif; ?>

        <h3>Add new FAQ</h3>
        <form method="POST" class="form-grid">
            <input type="hidden" name="action" value="create">
            <input type="text" name="question" placeholder="Question" required>
            <textarea name="answer" rows="3" placeholder="Answer" required></textarea>
            <label><input type="checkbox" name="is_active" checked> Active</label>
            <div class="actions">
                <button type="submit" class="btn btn-primary">Add FAQ</button>
                <button type="reset" class="btn btn-secondary">Reset</button>
            </div>
        </form>

        <h3>All FAQs</h3>
        <?php foreach ($faqs as $f): ?>
            <div class="faq-row">
                <form method="POST" class="form-grid">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="id" value="<?= (int)$f['id'] ?>">
                    <input type="text" name="question" value="<?= h($f['question']) ?>" required>
                    <textarea name="answer" rows="3" required><?= h($f['answer']) ?></textarea>
                    <label><input type="checkbox" name="is_active" <?= $f['is_active'] ? 'checked' : '' ?>> Active</label>
                    <div class="actions">
                        <button type="submit" class="btn btn-primary">Save</button>
                        <button formmethod="POST" formaction="admin_faqs.php" name="action" value="delete" class="btn btn-secondary" onclick="return confirm('Delete this FAQ?')">Delete</button>
                        <input type="hidden" name="id" value="<?= (int)$f['id'] ?>">
                    </div>
                </form>
            </div>
        <?php endforeach; ?>
    </main>
    <?php include __DIR__ . '/inc/site_footer.php'; ?>
</body>
</html>
