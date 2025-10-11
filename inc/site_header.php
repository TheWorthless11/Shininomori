<?php
// Common site header include
if (function_exists('session_status')) {
    if (session_status() === PHP_SESSION_NONE) { session_start(); }
} else {
    @session_start();
}

// Allow pages to set $activePage to one of: 'home','search','browse','sellers','start-selling'
$active = isset($activePage) ? $activePage : '';
?>
<header>
    <div class="top-bar">
        <span>Welcome!</span>
        <?php if (!empty($_SESSION['user_id'])): ?>
            <a href="#" id="order-track">Order Track</a>
        <?php endif; ?>
        <a href="donate.html">Book Donation</a>
    </div>
    <div class="main-header">
        <div class="header-left">
            <a href="index.php" class="logo">
                <img src="others/freepik-vintage-elegant-book-store-logo-20250927055224SgR2.png" alt="ShiniNoMori Logo" style="height:150px;display:block;">
            </a>
        </div>
        <div class="header-center">
            <form id="search-form-header" action="browse.php" method="GET">
                <input type="text" name="keywords" placeholder="Search by title, author, ISBN" value="<?= htmlspecialchars($_GET['keywords'] ?? '', ENT_QUOTES, 'UTF-8') ?>">
                <button type="submit">Search</button>
            </form>
        </div>
        <div class="header-right">
            <a href="signin.php" id="signin-link">Hello, Sign In</a>
            <a href="cart.html" id="cart-link" style="display:none;">Cart</a>
            <a href="faq.html">Help</a>
        </div>
    </div>
    <nav class="nav-bar">
    <a href="index.php" class="<?= $active==='home' ? 'active' : '' ?>">Home</a>
    <a href="advance_search.php" class="<?= $active==='search' ? 'active' : '' ?>">Advance Search</a>
        <a href="browse.php" class="<?= $active==='browse' ? 'active' : '' ?>">Browse Books</a>
        <a href="sellers.php" class="<?= $active==='sellers' ? 'active' : '' ?>">Sellers</a>
        <a href="start-selling.php" id="start-selling-link" class="<?= $active==='start-selling' ? 'active' : '' ?>">Start Selling</a>
    </nav>
</header>
