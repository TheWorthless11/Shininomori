// --- Random Quote ---
const quotes = [
    "A room without books is like a body without a soul. – Cicero",
    "So many books, so little time. – Frank Zappa",
    "Books are a uniquely portable magic. – Stephen King",
    "There is no friend as loyal as a book. – Ernest Hemingway",
    "Reading is dreaming with open eyes. – Anissa Trisdianty"
];
function showRandomQuote() {
    const quoteEl = document.getElementById('random-quote');
    if (quoteEl) {
        const idx = Math.floor(Math.random() * quotes.length);
        quoteEl.textContent = quotes[idx];
    }
}
showRandomQuote();

// --- Featured Books (Demo Data) ---
const featuredBooks = [
    {
        title: "Pride and Prejudice",
        author: "Jane Austen",
        price: "₹350",
        condition: "Good",
        seller: "BookWorld",
        link: "book-details.html?id=1"
    },
    {
        title: "The Hobbit",
        author: "J.R.R. Tolkien",
        price: "₹420",
        condition: "Very Good",
        seller: "ClassicReads",
        link: "book-details.html?id=2"
    },
    {
        title: "1984",
        author: "George Orwell",
        price: "₹300",
        condition: "Fair",
        seller: "OldPages",
        link: "book-details.html?id=3"
    }
];

function showFeaturedBooks() {
    const container = document.getElementById('featured-books');
    if (!container) return;
    container.innerHTML = '';
    featuredBooks.forEach(book => {
        const card = document.createElement('div');
        card.className = 'book-card';
        card.innerHTML = `
            <h3>${book.title}</h3>
            <p><strong>Author:</strong> ${book.author}</p>
            <p><strong>Price:</strong> ${book.price}</p>
            <p><strong>Condition:</strong> ${book.condition}</p>
            <p><strong>Seller:</strong> ${book.seller}</p>
            <a href="${book.link}" class="view-btn">View</a>
        `;
        container.appendChild(card);
    });
}
showFeaturedBooks();

// --- Cart & Login Logic (Demo) ---
function updateHeaderForUser() {
    // Simulate user type: 'buyer', 'seller', or null
    const userType = localStorage.getItem('userType'); // Set this on login
    const cartLink = document.getElementById('cart-link');
    const orderTrack = document.getElementById('order-track');
    const startSelling = document.getElementById('start-selling-link');

    if (userType === 'buyer') {
        cartLink.style.display = 'inline-block';
        orderTrack.onclick = () => window.location.href = 'orders.html';
        startSelling.onclick = () => window.location.href = 'start-selling.html';
    } else if (userType === 'seller') {
        cartLink.style.display = 'none';
        orderTrack.onclick = () => window.location.href = 'seller-orders.html';
        startSelling.onclick = () => window.location.href = 'seller-profile.html';
    } else {
        cartLink.style.display = 'none';
        orderTrack.onclick = () => window.location.href = 'signin.html';
        startSelling.onclick = () => window.location.href = 'signin.html';
    }
}
updateHeaderForUser();