-- Options
local AMOUNTS = {100, 500, 1000, 2000, 3200, 6400}

-- Placeholder functions
function deposit(amount, json_encode)
    local url = "http://127.0.0.1:5000/deposit-"..tostring(amount/100)
    local contentType = { ["Content-Type"] = "application/json" }
    local chestDeposit = ""
    local chestBank = ""
    local chestDepositWrap = peripheral.wrap(chestDeposit)
    local chestBankWrap = peripheral.wrap(chestBank)
    if not checkProxyRunning() then
        print("PROXY IS NOT RUNNING. Do not attempt any operations and notify support ASAP")
        return
    end

    if not checkSlots() then
        print("Deposit chest has invalid items. Please remove them before depositing.")
        return
    end

    if not checkSlotQuantity(amount) then
        print("Deposit chest does not have enough coins. Please add more coins before depositing.")
        return
    end
    
    h = http.post(url, json_encode, contentType)
    if h == nil then
        print("Failed to Deposit. Please contact support")
        return
    end
    print("Depositing of $" .. amount .. " Successful")
    local response = chestBankWrap.pullItems(peripheral.getName(chestDepositWrap), 1, amount/100)
end

function withdraw(amount, json_encode)
    local url = "http://127.0.0.1:5000/withdraw-"..tostring(amount/100)
    local contentType = { ["Content-Type"] = "application/json" }
    local chestDeposit = ""
    local chestBank = ""
    local chestDepositWrap = peripheral.wrap(chestDeposit)
    local chestBankWrap = peripheral.wrap(chestBank)

    if not checkProxyRunning() then
        print("PROXY IS NOT RUNNING. Do not attempt any operations and notify support ASAP")
        return
    end

    h = http.post(url, json_encode, contentType)
    if h == nil then
        print("Failed to withdraw. Please contact support")
        return
    end
    print("Withdrawing of $" .. amount .. " Successful")
    local response = chestBankWrap.pushItems(peripheral.getName(chestDepositWrap), 1, amount/100)
    
end

-- Helper function to get input from user
function prompt(message)
    io.write(message)
    return io.read()
end

function checkProxyRunning()
    local url = "http://127.0.0.1:5000/proxy-test"
    local h = http.get(url)
    if h == nil then
        return false
    end
    return true
end

function checkSlots()
    local chestDeposit = ""
    local chestDepositWrap = peripheral.wrap(chestDeposit)
    local items = chestDepositWrap.list()
    local isValid = true
    for slot, item in pairs(items) do
        if item.name ~= "lightmanscurrency:coin_diamond" then
            isValid = false
            print("Invalid item in deposit chest at slot " .. slot .. ": " .. item.name)
            
        end
    end
    if isValid then
        return true
    else
        print("Nice try, but please don't try to cheat the system if you find a way it just ruins it for the rest of us")
        return false
    end
end

function checkSlotQuantity(amount)
    local chestDeposit = ""
    local chestDepositWrap = peripheral.wrap(chestDeposit)
    local items = chestDepositWrap.list()
    local isValid = false
    for slot, item in pairs(items) do
        if slot == 1 then
            if item.count >= amount/100 then
                isValid = true
            end
        end
    end
    if isValid then
        return true
    else
        return false
    end
end

function getUserId(email, password)
    local test = checkProxyRunning()
    if not test then
        print("PROXY IS NOT RUNNING. Do **NOT** attempt any operations and notify support ASAP")
        return nil
    end
    local url = "http://127.0.0.1:5000/login"
    local json_encode = '{"email": "'..email..'", "password": "'..password..'"}'
    local request = http.post("http://127.0.0.1:5000/login", json_encode, { ["Content-Type"] = "application/json" })
    if request == nil then
        print("Failed to login. Please check your credentials or contact support")
        return nil
    end
    local result = request.readAll()
    print("Login Successful. User ID: " .. result)
    return result
end



-- URL Check

if not checkProxyRunning() then
    print("PROXY IS NOT RUNNING. Do not attempt any operations and notify support ASAP")
    return
end

print("Proxy is running. You can proceed with operations.")


-- Step 1: Get user credentials
local userId = nil
while true do
    io.write("Enter your email: ")
    local email = io.read()
    io.write("Enter your password: ")
    local password = io.read()

    if email and password then
        userId = getUserId(email, password)
        if userId then
            break
        else
            print("Invalid credentials. Please try again.")
        end
    else
        print("Email and password cannot be empty. Please try again.")
    end
end

while true do

    -- Step 2: Prompt for action
    local action = nil
    while true do
        print("Choose an action:")
        print("1. Withdraw")
        print("2. Deposit")
        io.write("> ")
        local input = io.read():lower()

        if input == "1" or input == "withdraw" then
            action = "withdraw"
            break
        elseif input == "2" or input == "deposit" then
            action = "deposit"
            break
        else
            print("Invalid input. Please enter '1', '2', 'withdraw', or 'deposit'.")
        end
    end

    -- Step 3: Prompt for amount
    local amount = nil
    while true do
        print("Select amount:")
        for i, amt in ipairs(AMOUNTS) do
            print(i .. ". $" .. amt)
        end
        io.write("> ")
        local input = io.read()

        -- Try parsing input as index
        local num = tonumber(input)
        if num then
            if AMOUNTS[num] then
                amount = AMOUNTS[num]
                break
            else
                -- Maybe they typed the actual amount
                for _, amt in ipairs(AMOUNTS) do
                    if amt == num then
                        amount = amt
                        break
                    end
                end
                if amount then break end
            end
        end
        print("Invalid input. Please enter a valid option number or amount.")
    end

    -- Step 4: Call appropriate function
    if action == "withdraw" then
        local json_encode = '{"user_id":"'..userId..'"}'
        withdraw(amount, json_encode)
    elseif action == "deposit" then
        local json_encode = '{"user_id":"'..userId..'"}'
        deposit(amount, json_encode)
    end

    -- Step 5: Ask if user wants to continue
    io.write("Do you want to perform another operation? (yes/no): ")
    local continue = io.read():lower()
    if continue ~= "yes" and continue ~= "y" then
        print("Thank you for using the system. Goodbye!")
        break
    end
    print("Continuing to the next operation...")
    print("--------------------------------------------------")
end