extension StringExtension on String {
  String capitalize() {
    return this.split('_').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
}
