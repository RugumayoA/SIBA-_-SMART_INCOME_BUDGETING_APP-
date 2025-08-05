# SIBA Budget Manager

A comprehensive Flutter-based mobile application designed to help users manage and allocate daily income into custom budget categories. Perfect for daily earners, site managers, and project managers who need practical financial planning tools.

## 🎯 Core Features

- **📊 Dashboard Overview** - Clear visual summary of total budget and category allocations
- **💰 Income Management** - Add daily income with instant allocation across categories
- **💸 Expense Tracking** - Record expenses with automatic deduction from appropriate categories
- **📱 Account Management** - Add, edit, and delete budget accounts/categories
- **🎨 Custom Categories** - Create personalized budget categories with custom colors
- **📈 Visual Analytics** - Progress bars and spending indicators for each category
- **💾 Offline Access** - All data stored locally with no internet dependency
- **🔄 Transaction History** - Complete record of all income and expenses

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Android Emulator or Physical Device

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd siba_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📱 App Features

### Dashboard
- **Total Money Display** - Prominent blue card showing total money across all accounts
- **Available vs Spent** - Clear breakdown of available money and total spent
- **Category Grid** - 2x2 grid showing all budget categories with current balances
- **Quick Action Buttons** - Add Income and Add Expense buttons for immediate access
- **Recent Transactions** - List of latest income and expense entries
- **Floating Action Button** - Quick expense entry

### Income Management
- **Account-Specific Income** - Add income directly to specific accounts
- **Total Income Entry** - Enter total daily/weekly income with allocation
- **Category Allocation** - Distribute income across multiple categories
- **Real-time Validation** - Ensures allocations match total income
- **Summary View** - Shows allocation breakdown and remaining amounts

### Expense Tracking
- **Account-Specific Expenses** - Add expenses directly to specific accounts
- **Category Selection** - Choose from existing budget categories
- **Amount Validation** - Prevents overspending beyond available amounts
- **Budget Summary** - Shows category spending progress and remaining budget
- **Description Tracking** - Detailed expense descriptions for better tracking

### Transaction History
- **Complete Transaction Log** - View all income and expense transactions
- **Detailed Information** - Shows account name, amount, date, and description
- **Chronological Order** - Transactions sorted by date (newest first)
- **Visual Indicators** - Color-coded income (green) and expenses (red)
- **Timestamps** - Exact date and time for each transaction

### Budget Categories
- **Default Categories** - Airtime, Food, Clothes, Savings
- **Visual Indicators** - Color-coded categories with progress bars
- **Spending Alerts** - Warning indicators when approaching budget limits
- **Remaining Balance** - Real-time calculation of available funds

### Account Management
- **Add New Accounts** - Create custom budget categories with personalized names
- **Edit Existing Accounts** - Modify account names, amounts, and colors
- **Delete Accounts** - Remove unused categories with confirmation
- **Color Customization** - Choose from 10 different colors for visual distinction
- **Quick Access** - Manage accounts from dashboard or navigation drawer

## 🏗️ Project Structure

```
lib/
├── main.dart                    # App entry point
├── providers/
│   └── app_provider.dart       # State management & data models
├── screens/
│   ├── home_screen.dart        # Main dashboard
│   ├── add_income_screen.dart  # Income entry screen
│   ├── add_expense_screen.dart # Expense entry screen
│   └── manage_accounts_screen.dart # Account management screen
└── widgets/
    ├── budget_category_card.dart # Category display widget
    ├── transaction_item.dart    # Transaction list item
    ├── custom_card.dart         # Reusable card widget
    └── feature_item.dart        # Legacy feature widget
```

## 💾 Data Models

### BudgetCategory
- `id`: Unique identifier
- `name`: Category name
- `allocatedAmount`: Total budget allocated
- `spentAmount`: Amount spent so far
- `color`: Visual color for the category
- `remainingAmount`: Calculated remaining budget
- `spentPercentage`: Percentage of budget used

### Transaction
- `id`: Unique identifier
- `categoryId`: Associated budget category
- `description`: Transaction description
- `amount`: Transaction amount
- `date`: Transaction date
- `isExpense`: Boolean flag for income/expense

## 🔧 Dependencies

- **flutter**: Core Flutter framework
- **provider**: State management
- **shared_preferences**: Local data persistence
- **intl**: Date formatting and localization
- **http**: HTTP requests (for future features)
- **flutter_svg**: SVG support (for future features)
- **cached_network_image**: Image caching (for future features)

## 🎨 UI/UX Features

- **Material 3 Design** - Modern, clean interface
- **Responsive Layout** - Works on all screen sizes
- **Color-coded Categories** - Visual distinction between budget areas
- **Progress Indicators** - Visual feedback on spending progress
- **Intuitive Navigation** - Easy-to-use interface for daily use
- **Offline Functionality** - No internet required for core features

## 💡 Use Cases

### For Daily Earners
- Track daily income and allocate to essential categories
- Monitor spending patterns and stay within budgets
- Plan for savings and future expenses

### For Site Managers
- Track project expenses and material costs
- Monitor daily site expenditures
- Replace traditional notebook tracking with digital solution

### For Project Managers
- Manage project budgets across different categories
- Track team expenses and allocations
- Maintain detailed financial records

## 🔄 State Management

- **Provider Pattern** - Clean separation of concerns
- **Persistent Storage** - All data saved locally
- **Real-time Updates** - UI updates immediately on data changes
- **Data Validation** - Prevents invalid entries and overspending

## 🚀 Future Enhancements

- **User Authentication** - Secure login system
- **Data Export** - Export transactions to CSV/PDF
- **Cloud Sync** - Backup data to cloud storage
- **Analytics Dashboard** - Detailed spending insights
- **Budget Templates** - Pre-configured budget categories
- **Multi-currency Support** - Support for different currencies
- **Team Collaboration** - Share budgets with team members

## 📱 Building for Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

For support and questions, please open an issue in the repository. 