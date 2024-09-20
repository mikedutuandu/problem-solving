
class Solution:


    def constains_duplicate(self,nums):
        result = false
        check = {}
        while i < len(nums):
            if nums[i] in check.keys():
                check[i] = check[i] + 1
            else:
                check[i] = 1

            if check[i] >= 2:
                return true
            i++


        return result
