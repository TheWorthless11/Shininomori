<?php
// Home page using common header/footer
session_start();
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Old Book Store</title>
    <link rel="stylesheet" href="styles/main.css">
    <link rel="stylesheet" href="styles/components.css">
</head>
<body>
    <?php $activePage = 'home'; include __DIR__ . '/inc/site_header.php'; ?>

    <main>
        <h1>Welcome to Old Book Store – Buy & Sell Books Easily</h1>
        <blockquote id="random-quote"></blockquote>
        <section id="featured-books">
            <!-- Featured books will be loaded here -->
        </section>
        <a href="browse.php" class="explore-btn">Explore All Books</a>
    </main>

    <?php include __DIR__ . '/inc/site_footer.php'; ?>
    <script src="src/app.js"></script>
</body>
</html>
