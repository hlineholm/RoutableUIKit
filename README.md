# RoutableUIKit
Routable UIKit components which are agnostic of your custom routing logic
## Getting Started
### RoutableNavigationController (RNC) and RoutableNavigationControllerDelegate (RNCD)
1. Create an instance of the navigation controller
2. Conform to the RNCD and set the routing delegate of the instance you've created
3. Use the delegate methods to update your routing state:
- Read and write the route property of the RNC to synchronize it with your router
- Use the sender property of the RNC push/pop methods to detect who initiated the action
## License
This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
