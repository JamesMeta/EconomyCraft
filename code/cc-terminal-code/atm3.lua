zz = "minecraft:chest_8"


function aq(vs, yn)
    local pq = "http://127.0.0.1:5000/deposit-"..tostring(vs/100)
    local ts = { ["Content-Type"] = "application/json" }
    local kx = zz
    local zx = yy
    local uy = peripheral.wrap(kx)
    local jd = peripheral.wrap(zx)

    if not mp() then
        print("PROXY IS NOT RUNNING. Do not attempt any operations and notify support ASAP")
        return
    end

    if not sw() then
        print("Deposit chest has invalid items. Please remove them before depositing.")
        return
    end

    if not qo(vs) then
        print("Deposit chest does not have enough coins. Please add more coins before depositing.")
        return
    end

    local bd = http.post(pq, yn, ts)
    if bd == nil then
        print("Failed to Deposit. Please contact support")
        return
    end
    print("Depositing of $" .. vs .. " Successful")
    local rh = jd.pullItems(peripheral.getName(uy), 1, vs/100)
end

function wf(vs, yn)
    local pq = "http://127.0.0.1:5000/withdraw-"..tostring(vs/100)
    local ts = { ["Content-Type"] = "application/json" }
    local kx = zz
    local zx = xx
    local uy = peripheral.wrap(kx)
    local jd = peripheral.wrap(zx)

    if not mp() then
        print("PROXY IS NOT RUNNING. Do not attempt any operations and notify support ASAP")
        return
    end

    local bd = http.post(pq, yn, ts)
    if bd == nil then
        print("Failed to withdraw. Please contact support")
        return
    end
    print("Withdrawing of $" .. vs .. " Successful")
    local rh = jd.pushItems(peripheral.getName(uy), 1, vs/100)
end

function xb(cq)
    io.write(cq)
    return io.read()
end

function mp()
    local pq = "http://127.0.0.1:5000/proxy-test"
    local bd = http.get(pq)
    if bd == nil then
        return false
    end
    return true
end

function sw()
    local kx = zz
    local uy = peripheral.wrap(kx)
    local qd = uy.list()
    local gr = true
    for dm, hr in pairs(qd) do
        if hr.name ~= "lightmanscurrency:coin_diamond" then
            gr = false
            print("Invalid item in deposit chest at slot " .. dm .. ": " .. hr.name)
        end
    end
    if gr then
        return true
    else
        print("Nice try, but please don't try to cheat the system if you find a way it just ruins it for the rest of us")
        return false
    end
end

function qo(vs)
    local kx = zz
    local uy = peripheral.wrap(kx)
    local qd = uy.list()
    local gr = false
    for dm, hr in pairs(qd) do
        if dm == 1 then
            if hr.count >= vs/100 then
                gr = true
            end
        end
    end
    return gr
end

function mu(an, cz)
    local yt = mp()
    if not yt then
        print("PROXY IS NOT RUNNING. Do **NOT** attempt any operations and notify support ASAP")
        return nil
    end
    local pq = "http://127.0.0.1:5000/login"
    local yn = '{"email": "'..an..'", "password": "'..cz..'"}'
    local bd = http.post(pq, yn, { ["Content-Type"] = "application/json" })
    if bd == nil then
        print("Failed to login. Please check your credentials or contact support")
        return nil
    end
    local bh = bd.readAll()
    print("Login Successful. User ID: " .. bh)
    return bh
end

xk = {100, 500, 1000, 2000, 3200, 6400}

yy = "minecraft:chest_10"
xx = "minecraft:chest_11"

if not mp() then
    print("PROXY IS NOT RUNNING. Do not attempt any operations and notify support ASAP")
    return
end

print("Proxy is running. You can proceed with operations.")

local dp = nil
while true do
    io.write("Enter your email: ")
    local an = io.read()
    io.write("Enter your password: ")
    local cz = io.read()

    if an and cz then
        dp = mu(an, cz)
        if dp then
            break
        else
            print("Invalid credentials. Please try again.")
        end
    else
        print("Email and password cannot be empty. Please try again.")
    end
end

while true do

    local yv = nil
    while true do
        print("Choose an action:")
        print("1. Withdraw")
        print("2. Deposit")
        io.write("> ")
        local qu = io.read():lower()

        if qu == "1" or qu == "withdraw" then
            yv = "withdraw"
            break
        elseif qu == "2" or qu == "deposit" then
            yv = "deposit"
            break
        else
            print("Invalid input. Please enter '1', '2', 'withdraw', or 'deposit'.")
        end
    end

    local vs = nil
    while true do
        print("Select amount:")
        for jh, lu in ipairs(xk) do
            print(jh .. ". $" .. lu)
        end
        io.write("> ")
        local qu = io.read()
        local mv = tonumber(qu)
        if mv then
            if xk[mv] then
                vs = xk[mv]
                break
            else
                for _, lu in ipairs(xk) do
                    if lu == mv then
                        vs = lu
                        break
                    end
                end
                if vs then break end
            end
        end
        print("Invalid input. Please enter a valid option number or amount.")
    end

    if yv == "withdraw" then
        local yn = '{"user_id":"'..dp..'"}'
        wf(vs, yn)
    elseif yv == "deposit" then
        local yn = '{"user_id":"'..dp..'"}'
        aq(vs, yn)
    end
    print("Operation completed. You can perform another operation or exit.")
    print("Do you want to perform another operation? (yes/no)")
    io.write("> ")
    local qu = io.read():lower()
    if qu ~= "yes" and qu ~= "y" then
        print("Thank you for using the ATM. Goodbye!")
        break
    end
end

