def findPivot(nums):
    if len(nums) == 1 or nums[-1] > nums[0]:
        return 0
    start = 0
    end = len(nums) - 1
    while start <= end:
        mid = start + (end - start) / 2
        if nums[mid] > nums[mid + 1]:
            return mid + 1
        if nums[mid] < nums[start]:
            end = mid - 1
        else:
            start = mid + 1

def findPivot_rec(nums, l, r):
    if len(nums) == 1 or nums[-1] > nums[0]:
        return 0
    if l <= r:
        mid = l + (r - l) / 2
        if nums[mid] > nums[mid + 1]:
            return mid + 1

# print findPivot([4,5,1,2,3])

def binarySearch(arr, l, r, x):
    while l <= r:

        mid = l + (r - l) // 2;

        # Check if x is present at mid
        if arr[mid] == x:
            return mid

            # If x is greater, ignore left half
        elif arr[mid] < x:
            l = mid + 1

        # If x is smaller, ignore right half
        else:
            r = mid - 1

    # If we reach here, then the element
    # was not present
    return -1
# print binarySearch([1,2],0,1,2)

class LargerNumKey(str):
    def __lt__(x, y):
        return x+y > y+x
def largestNumber(nums):
    largest_num = ''.join(sorted(map(str, nums), key=LargerNumKey))
    return '0' if largest_num[0] == '0' else largest_num
nums = [41,42,24,4,5]


def reverse(input_l):
    for i in range((len(input_l)) / 2):
        input_l[i] = input_l[len(input_l) - i - 1]
    return input_l

fibb = {0:2, 1:3}
memo = {0:1, 1:2, 3:3}
def solve(num):
    def app_log(x):
        res = 0
        temp = x
        while x / 2 > 0:
            x /= 2
            res += 1
        rem = temp - pow(2, res)
        return res, rem
    def fib(x):
        if x not in fibb:
            fibb[x] = fib(x-1) + fib(x-2)
        return fibb[x]
    # if num == 3:
    #     print num in memo, memo[num], 'os'
    if num not in memo:
        po, rem = app_log(num)
        # print po, rem
        res_f = fib(po - 1)
        memo[num] = res_f + solve(rem)
    return memo[num]
def app_log(x):
    res = 0
    temp = x
    while x / 2 > 0:
        x /= 2
        res += 1
    rem = temp - pow(2, res)
    return res, rem

def powerset(input):
    res = []
    def helper(input, index, cons):
        if index == len(input):
            res.append(cons)
            return
        helper(input, index+1, cons+input[index])
        helper(input, index+1, cons)
    helper(input, 0, '')
    return res

def colorful(num):
    num = str(num)
    res = set()
    subsets = []
    def helper(input, index, cons, mul):
        if len(cons) != 0 and len(cons) != len(input):
            subsets.append(cons)
            if mul not in res:
                res.add(mul)
            else:
                return
        if index == len(input):
            return
        helper(input, index+1, cons+input[index], mul*int(input[index]))
    for i in range(len(num)):
        helper(num, i, '', 1)
    print res, subsets
    return len(res) == len(subsets)
# print(colorful(326))

def fib(n):
    # if n == 1 or n == 2:
    #     return 1
    # return fib(n - 1) + fib(n - 2)

    memo = [0] * (n+1)
    memo[1] = memo[2] = 1
    def helper(n):
        if memo[n] == 0:
            memo[n] = helper(n - 1) + helper(n - 2)
        return memo[n]
    helper(n)
    return memo[-1]
# print(fib(24))

def partition(arr, l, r):
    i = l
    pivot = arr[r]
    for j in range(l, r):
        if arr[j] <= pivot:
            arr[i], arr[j] = arr[j], arr[i]
            i += 1
    arr[i], arr[r] = arr[r], arr[i]
    return i

def quicksort(arr, l, r):
    if l < r:
        pivot = partition(arr, l ,r)
        quicksort(arr, l, pivot - 1)
        quicksort(arr, pivot + 1, r)

def merge(arr1, arr2):
    res = []
    while len(arr1) != 0 and len(arr2) != 0:
        if arr1[0] > arr2[0]:
            res.append(arr2.pop(0))
        else:
            res.append(arr1.pop(0))
    if arr1:
        res += arr1
    if arr2:
        res += arr2
    return res

def mergeSort(arr):
    if len(arr) > 1:
        mid = len(arr)//2
        left = mergeSort(arr[:mid])
        right = mergeSort(arr[mid:])
        return merge(left, right)
    else:
        return arr

def mergeSortInPlace(arr):
    if len(arr) > 1:
        mid = len(arr)//2
        L = arr[:mid]
        R = arr[mid:]
        mergeSortInPlace(L)
        mergeSortInPlace(R)
        i = j = k = 0
        while i < len(L) and j < len(R):
            if L[i] < R[j]:
                arr[k] = L[i]
                i += 1
            else:
                arr[k] = R[j]
                j += 1
            k += 1
        while i < len(L):
            arr[k] = L[i]
            i += 1
            k += 1
        while j < len(R):
            arr[k] = R[j]
            j += 1
            k += 1

s