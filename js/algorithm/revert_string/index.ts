
function reverseString(s: string): string {
    let reversed = '';
    for (let i = s.length - 1; i >= 0; i--) {
        reversed += s[i];
    }
    return reversed;
}