<?php
// inc/faq.php - helpers for FAQs (seller questions)

if (!function_exists('faq_ensure_table')) {
    function faq_ensure_table(mysqli $mysqli): void {
        $sql = "CREATE TABLE IF NOT EXISTS faqs (
            id INT AUTO_INCREMENT PRIMARY KEY,
            question TEXT NOT NULL,
            answer TEXT NOT NULL,
            is_active TINYINT(1) NOT NULL DEFAULT 1,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
        mysqli_query($mysqli, $sql);
    }
}

if (!function_exists('faq_all')) {
    function faq_all(mysqli $mysqli, bool $only_active = true, ?int $limit = null): array {
        faq_ensure_table($mysqli);
        $where = $only_active ? 'WHERE is_active = 1' : '';
        $limitSql = ($limit && $limit > 0) ? ' LIMIT ' . (int)$limit : '';
        $res = mysqli_query($mysqli, "SELECT id, question, answer, is_active, created_at, updated_at FROM faqs {$where} ORDER BY id DESC{$limitSql}");
        $rows = [];
        if ($res) { while ($r = mysqli_fetch_assoc($res)) { $rows[] = $r; } }
        return $rows;
    }
}

if (!function_exists('faq_get')) {
    function faq_get(mysqli $mysqli, int $id): ?array {
        faq_ensure_table($mysqli);
        $stmt = mysqli_prepare($mysqli, 'SELECT id, question, answer, is_active FROM faqs WHERE id = ? LIMIT 1');
        if (!$stmt) return null;
        mysqli_stmt_bind_param($stmt, 'i', $id);
        mysqli_stmt_execute($stmt);
        $res = mysqli_stmt_get_result($stmt);
        $row = $res ? mysqli_fetch_assoc($res) : null;
        mysqli_stmt_close($stmt);
        return $row ?: null;
    }
}

if (!function_exists('faq_create')) {
    function faq_create(mysqli $mysqli, string $question, string $answer, int $is_active = 1): bool {
        faq_ensure_table($mysqli);
        $stmt = mysqli_prepare($mysqli, 'INSERT INTO faqs (question, answer, is_active) VALUES (?,?,?)');
        if (!$stmt) return false;
        mysqli_stmt_bind_param($stmt, 'ssi', $question, $answer, $is_active);
        $ok = mysqli_stmt_execute($stmt);
        mysqli_stmt_close($stmt);
        return $ok;
    }
}

if (!function_exists('faq_update')) {
    function faq_update(mysqli $mysqli, int $id, string $question, string $answer, int $is_active = 1): bool {
        faq_ensure_table($mysqli);
        $stmt = mysqli_prepare($mysqli, 'UPDATE faqs SET question = ?, answer = ?, is_active = ? WHERE id = ?');
        if (!$stmt) return false;
        mysqli_stmt_bind_param($stmt, 'ssii', $question, $answer, $is_active, $id);
        $ok = mysqli_stmt_execute($stmt);
        mysqli_stmt_close($stmt);
        return $ok;
    }
}

if (!function_exists('faq_delete')) {
    function faq_delete(mysqli $mysqli, int $id): bool {
        faq_ensure_table($mysqli);
        $stmt = mysqli_prepare($mysqli, 'DELETE FROM faqs WHERE id = ?');
        if (!$stmt) return false;
        mysqli_stmt_bind_param($stmt, 'i', $id);
        $ok = mysqli_stmt_execute($stmt);
        mysqli_stmt_close($stmt);
        return $ok;
    }
}
?>
