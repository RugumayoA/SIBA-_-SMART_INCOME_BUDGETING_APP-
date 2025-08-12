# SIBA Budget Manager

A comprehensive Flutter-based mobile application designed to help users manage multiple budget projects with custom categories. Perfect for daily earners, site managers, and project managers who need to track budgets across different projects, properties, or time periods.

## 🎯 Core Features

- **🗂️ Multi-Project Management** - Create and manage unlimited budget projects
- **📊 Dashboard Overview** - Clear visual summary of total budget and category allocations per project
- **🔄 Project Switching** - Seamlessly switch between different budget projects
- **💰 Income Management** - Add daily income with instant allocation across categories
- **💸 Expense Tracking** - Record expenses with automatic deduction from appropriate categories
- **📱 Account Management** - Add, edit, and delete budget accounts/categories
- **🎨 Custom Categories** - Create personalized budget categories with custom colors
- **📈 Visual Analytics** - Progress bars and spending indicators for each category
- **☁️ Cloud Sync** - All data synced to Firebase with real-time updates
- **🔐 User Authentication** - Secure login with Firebase Auth
- **🔄 Transaction History** - Complete record of all income and expenses per project

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Firebase account (for backend services)
- Android Studio / VS Code
- Android Emulator or Physical Device

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd SIBA
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a new Firebase project
   - Enable Authentication (Email/Password)
   - Enable Firestore Database
   - Download `google-services.json` and place in `android/app/`
   - Update Firebase configuration in `lib/firebase_options.dart`

4. **Run the app**
   ```bash
   flutter run
   ```

## 📱 App Features

### Projects Management
- **Projects List** - View all your budget projects after login
- **Create Projects** - Add new projects with custom names, descriptions, budgets, and colors
- **Edit Projects** - Modify project details including name, description, and budget
- **Duplicate Projects** - Copy existing projects for similar budget scenarios
- **Delete Projects** - Remove projects with confirmation (deletes all associated data)
- **Project Selection** - Switch between projects to manage different budgets
- **Project Context** - Current project shown in dashboard header and drawer

### Dashboard (Per Project)
- **Total Money Display** - Prominent card showing total money across all accounts in current project
- **Available vs Spent** - Clear breakdown of available money and total spent for current project
- **Category Grid** - 2x2 grid showing all budget categories with current balances
- **Quick Action Buttons** - Add Income and Add Expense buttons for immediate access
- **Recent Transactions** - List of latest income and expense entries for current project
- **Project Navigation** - Easy switching between projects via app bar and drawer
- **Floating Action Button** - Quick expense entry

### Income Management (Per Project)
- **Account-Specific Income** - Add income directly to specific accounts in current project
- **Total Income Entry** - Enter total daily/weekly income with allocation
- **Category Allocation** - Distribute income across multiple categories within project
- **Real-time Validation** - Ensures allocations match total income
- **Summary View** - Shows allocation breakdown and remaining amounts
- **Project Isolation** - Income tracked separately for each project

### Expense Tracking (Per Project)
- **Account-Specific Expenses** - Add expenses directly to specific accounts in current project
- **Category Selection** - Choose from existing budget categories within project
- **Amount Validation** - Prevents overspending beyond available amounts
- **Budget Summary** - Shows category spending progress and remaining budget
- **Description Tracking** - Detailed expense descriptions for better tracking
- **Project-Based Tracking** - Expenses isolated per project

### Transaction History (Per Project)
- **Complete Transaction Log** - View all income and expense transactions for current project
- **Project Filtering** - Transactions filtered by selected project
- **Detailed Information** - Shows account name, amount, date, and description
- **Chronological Order** - Transactions sorted by date (newest first)
- **Visual Indicators** - Color-coded income (green) and expenses (red)
- **Timestamps** - Exact date and time for each transaction

### Budget Categories (Per Project)
- **Default Categories** - Airtime, Food, Clothes, Savings (created per project)
- **Visual Indicators** - Color-coded categories with progress bars
- **Spending Alerts** - Warning indicators when approaching budget limits
- **Remaining Balance** - Real-time calculation of available funds
- **Project-Specific** - Each project has its own set of categories

### Account Management (Per Project)
- **Add New Accounts** - Create custom budget categories with personalized names within current project
- **Edit Existing Accounts** - Modify account names, amounts, and colors for current project
- **Delete Accounts** - Remove unused categories with confirmation (project-specific)
- **Color Customization** - Choose from 8 different colors for visual distinction
- **Quick Access** - Manage accounts from dashboard or navigation drawer
- **Project Isolation** - Account changes only affect current project

### User Authentication
- **Email/Password Login** - Secure authentication via Firebase Auth
- **Account Registration** - Create new user accounts with email verification
- **Password Reset** - Reset forgotten passwords via email
- **Automatic Login** - Stay logged in across app sessions
- **Secure Logout** - Sign out and clear session data

## 🏗️ Project Structure

```
lib/
├── main.dart                       # App entry point with Firebase initialization
├── firebase_options.dart          # Firebase configuration
├── models/
│   └── project.dart               # Project data model
├── providers/
│   └── app_provider.dart          # State management & data models
├── screens/
│   ├── projects_screen.dart       # Project management screen
│   ├── home_screen.dart           # Main dashboard (per project)
│   ├── add_income_screen.dart     # Income entry screen
│   ├── add_expense_screen.dart    # Expense entry screen
│   ├── manage_accounts_screen.dart # Account management screen
│   ├── transaction_history_screen.dart # Transaction history
│   ├── add_income_to_account_screen.dart # Direct income entry
│   └── auth/
│       └── login_screen.dart      # Authentication screen
├── services/
│   ├── auth_service.dart          # Firebase Authentication
│   ├── firebase_service.dart      # Firestore operations
│   └── project_service.dart       # Project CRUD operations
└── widgets/
    ├── budget_category_card.dart  # Category display widget
    ├── transaction_item.dart      # Transaction list item
    ├── custom_card.dart           # Reusable card widget
    └── feature_item.dart          # Legacy feature widget
```

## 💾 Data Models

### Project
- `id`: Unique identifier
- `name`: Project name
- `description`: Project description
- `createdAt`: Creation timestamp
- `lastModified`: Last modification timestamp
- `color`: Project theme color
- `totalBudget`: Total project budget
- `currentBalance`: Current available balance

### BudgetCategory (Per Project)
- `id`: Unique identifier
- `name`: Category name
- `allocatedAmount`: Total budget allocated
- `spentAmount`: Amount spent so far
- `currentBalance`: Current available balance
- `color`: Visual color for the category
- `remainingAmount`: Calculated remaining budget
- `spentPercentage`: Percentage of budget used

### Transaction (Per Project)
- `id`: Unique identifier
- `categoryId`: Associated budget category
- `description`: Transaction description
- `amount`: Transaction amount
- `date`: Transaction date
- `isExpense`: Boolean flag for income/expense
- `categoryName`: Name of associated category

## 🔧 Dependencies

- **flutter**: Core Flutter framework
- **provider**: State management
- **firebase_core**: Firebase SDK integration
- **firebase_auth**: User authentication
- **cloud_firestore**: NoSQL database
- **intl**: Date formatting and localization

## 🎨 UI/UX Features

- **Material 3 Design** - Modern, clean interface following Google's design guidelines
- **Responsive Layout** - Optimized for all screen sizes and orientations
- **Project Color Themes** - Each project has its own color scheme reflected in UI
- **Color-coded Categories** - Visual distinction between budget areas
- **Progress Indicators** - Visual feedback on spending progress per category
- **Intuitive Navigation** - Easy switching between projects and screens
- **Real-time Updates** - Instant UI updates with Firebase real-time sync
- **Loading States** - Smooth loading indicators for better UX

## 💡 Use Cases

### Multi-Project Scenarios
- **Personal vs Business** - Separate budgets for personal and business expenses
- **Multiple Properties** - Individual budgets for different rental properties or investments
- **Family Members** - Separate budget tracking for different family members
- **Time Periods** - Monthly, quarterly, or yearly budget planning
- **Events** - Special event budgeting (weddings, vacations, conferences)
- **Goals** - Different financial goal tracking (emergency fund, vacation savings)

### For Daily Earners
- Track daily income across multiple income sources or projects
- Allocate income to different life areas (personal, business, savings)
- Monitor spending patterns across different budget scenarios
- Plan for multiple financial goals simultaneously

### For Site Managers
- Track expenses for multiple construction sites or projects
- Monitor material costs and labor expenses per project
- Compare budget performance across different sites
- Maintain separate records for different clients or contracts

### For Project Managers
- Manage budgets for multiple concurrent projects
- Track team expenses and resource allocations per project
- Compare financial performance across different projects
- Maintain detailed records for client billing and reporting

## 🔄 State Management & Data Architecture

- **Provider Pattern** - Clean separation of concerns with centralized state management
- **Firebase Firestore** - Cloud-based NoSQL database with real-time synchronization
- **Hierarchical Data Structure** - Users → Projects → Categories/Transactions
- **Real-time Updates** - UI updates immediately on data changes across devices
- **Data Validation** - Prevents invalid entries and overspending
- **Project Isolation** - Complete data separation between different projects
- **User Authentication** - Secure, user-specific data access
- **Offline Capability** - Firebase provides offline data caching

## 🗄️ Firebase Data Structure

```
Firestore Database:
├── users/{userId}/
│   └── projects/{projectId}/
│       ├── name: "Project Name"
│       ├── description: "Project Description"
│       ├── createdAt: Timestamp
│       ├── lastModified: Timestamp
│       ├── color: 0xFF6750A4
│       ├── totalBudget: 1500000
│       ├── currentBalance: 1200000
│       ├── categories/{categoryId}/
│       │   ├── name: "Food"
│       │   ├── allocatedAmount: 400000
│       │   ├── spentAmount: 150000
│       │   ├── currentBalance: 250000
│       │   └── color: 0xFF4CAF50
│       └── transactions/{transactionId}/
│           ├── categoryId: "category123"
│           ├── description: "Grocery shopping"
│           ├── amount: 25000
│           ├── date: Timestamp
│           ├── isExpense: true
│           └── categoryName: "Food"
```

### Security Rules
- Users can only access their own data
- All operations require authentication
- Project data is isolated per user
- Real-time updates are user-specific

## 🚀 Future Enhancements

- **Data Export** - Export project data and transactions to CSV/PDF
- **Analytics Dashboard** - Detailed spending insights and trends across projects
- **Budget Templates** - Pre-configured project templates for common scenarios
- **Multi-currency Support** - Support for different currencies per project
- **Team Collaboration** - Share projects with team members or family
- **Project Comparison** - Compare spending patterns between projects
- **Recurring Transactions** - Set up automatic recurring income/expenses
- **Budget Alerts** - Push notifications for budget limits and spending goals
- **Data Visualization** - Charts and graphs for better financial insights
- **Backup & Restore** - Manual backup and restore functionality

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